class Reservation < ApplicationRecord
  belongs_to :property
  belongs_to :user
  belongs_to :client, optional: true

  attr_accessor :skip_notifications

  enum :status, { pending: 0, confirmed: 1, cancelled: 2, blocked: 3 }

  has_secure_token :token
  def self.selectable_statuses
    statuses.keys.reject { |s| s == "blocked" }
  end

  scope :in_range, ->(range) { where(start_time: range) }
  scope :completed, -> { confirmed.where("end_time <= ?", Time.zone.now) }
  scope :projected, -> { confirmed.where("end_time > ?", Time.zone.now) }
  scope :active, -> { where.not(status: :cancelled) }
  scope :upcoming, -> { active.where("start_time >= ?", Time.zone.now).order(start_time: :asc) }

  validates :client_name, presence: true, unless: :blocked?
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :start_time_cannot_be_in_the_past, on: :create
  validate :end_time_after_start_time
  validate :no_overlapping_reservations
  validate :cannot_change_if_already_cancelled, on: :update

  scope :search, ->(query) {
    if query.present?
      joins(:property).where("client_name ILIKE ? OR properties.name ILIKE ?", "%#{query}%", "%#{query}%")
    else
      joins(:property)
    end
  }
  scope :ordered, -> { order(start_time: :desc) }

  scope :for_list, ->(query: nil, status: nil) {
    list = includes(:property).search(query).ordered
    list = list.where(status: status) if status.present?
    list
  }

  before_validation :sync_client_name
  before_validation :handle_blocked_reservation
  before_save :calculate_total_price
  after_commit :send_status_notifications, on: [ :create, :update ]
  after_commit :schedule_reminder_job, on: [ :create, :update ]

  def destroyable?
    blocked?
  end

  def status_text
    case status
    when "pending" then "Pendiente"
    when "confirmed" then "Confirmada"
    when "cancelled" then "Cancelada"
    when "blocked" then "Bloqueado / No Disponible"
    else status.humanize
    end
  end

  def status_color_classes
    case status
    when "pending" then "bg-amber-50 text-amber-600 border-amber-100"
    when "confirmed" then "bg-emerald-50 text-emerald-600 border-emerald-100"
    when "cancelled" then "bg-rose-50 text-rose-600 border-rose-100"
    when "blocked" then "bg-slate-700 text-white border-slate-800 shadow-sm"
    else "bg-gray-50 text-gray-600 border-gray-100"
    end
  end

  def self.for_calendar(property_id: nil, start_date_str: nil, end_date_str: nil, exclude_id: nil)
    query = Reservation.joins(:property).includes(:property)
    query = query.where(property_id: property_id) if property_id.present?

    if start_date_str.present? && end_date_str.present?
      start_date = Time.zone.parse(start_date_str) rescue nil
      end_date = Time.zone.parse(end_date_str) rescue nil
      if start_date && end_date
        query = query.where("start_time < ? AND end_time > ?", end_date, start_date)
      end
    end

    query = query.where.not(id: exclude_id) if exclude_id.present?
    query.order(start_time: :asc)
  end

  private

  def sync_client_name
    self.client_name = client.name if client.present?
  end

  def handle_blocked_reservation
    return unless blocked?

    self.client_name = "PROPIEDAD BLOQUEADA / MANTENCIÓN"
    self.client_id = nil
  end

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time < start_time
      errors.add(:end_time, "no puede ser anterior a la fecha de inicio")
    end
  end

  def start_time_cannot_be_in_the_past
    return if start_time.blank?

    if start_time < Time.zone.now.beginning_of_day
      errors.add(:start_time, "no puede ser en el pasado")
    end
  end

  def cannot_change_if_already_cancelled
    if status_was == "cancelled"
      errors.add(:base, "Esta reserva ya está cancelada y no puede ser modificada.")
    end
  end

  def no_overlapping_reservations
    return if property.blank? || start_time.blank? || end_time.blank?

    # Base query: same property, not cancelled, not itself
    # We include blocked status in the check
    scope = property.reservations.where.not(id: id).where.not(status: :cancelled)

    if property.per_day?
      overlapping = scope.where("CAST(start_time AS DATE) < CAST(? AS DATE) AND CAST(end_time AS DATE) > CAST(? AS DATE)",
                                end_time, start_time).first
    else
      overlapping = scope.where("start_time < ? AND end_time > ?", end_time, start_time).first
    end

    if overlapping
      format = property.per_hour? ? "%d-%m-%Y %H:%M" : "%d-%m-%Y"
      client_display = overlapping.blocked? ? "<b>BLOQUEO DE FECHA</b>" : "<b>#{overlapping.client_name}</b>"

      message = "La propiedad ya está #{overlapping.blocked? ? 'bloqueada' : 'reservada'} en estas fechas por " \
                "#{client_display}, desde el " \
                "#{overlapping.start_time.strftime(format)} al " \
                "#{overlapping.property.per_day? ? (overlapping.end_time - 1.day).strftime(format) : overlapping.end_time.strftime(format)} " \
                "(<a href='/reservations/#{overlapping.id}' " \
                "target='_blank' class='underline font-semibold " \
                "hover:text-red-900'>Ver #{overlapping.blocked? ? 'Bloqueo' : 'Reserva'} ##{overlapping.id}</a>)."
      errors.add(:base, message)
    end
  end

  def calculate_total_price
    return if property.blank? || start_time.blank? || end_time.blank?

    if property.per_day?
      days = (end_time.to_date - start_time.to_date).to_i
      days = 1 if days < 1
      self.total_price = days * property.base_price
    else
      hours = ((end_time - start_time) / 1.hour).ceil
      hours = 1 if hours < 1
      self.total_price = hours * property.base_price
    end
  end

  def send_status_notifications
    return if skip_notifications
    return unless saved_change_to_status? || saved_change_to_id?
    return if client.blank? || client.email.blank? || blocked?

    case status
    when "pending"
      ReservationMailer.pending_confirmation(self).deliver_now
    when "confirmed"
      ReservationMailer.confirmed(self).deliver_now
    when "cancelled"
      ReservationMailer.cancelled(self).deliver_now
    end
  end

  def schedule_reminder_job
    return unless confirmed? && !blocked?
    return if start_time < 24.hours.from_now
    return unless saved_change_to_start_time? || saved_change_to_status?

    ReservationReminderJob.set(wait_until: start_time - 24.hours).perform_later(self)
  end
end
