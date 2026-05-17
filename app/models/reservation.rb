class Reservation < ApplicationRecord
  belongs_to :property
  belongs_to :user
  belongs_to :client, optional: true
  has_many :payments, dependent: :destroy

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
  scope :active_and_valid, -> {
    where.not(status: :cancelled)
         .where.not("reservations.status = ? AND reservations.created_at < ?", Reservation.statuses[:pending], 24.hours.ago)
  }
  scope :upcoming, -> { active.where("start_time >= ?", Time.zone.now).order(start_time: :asc) }
  scope :overlapping_range, ->(start_time, end_time) {
    where("start_time < ? AND end_time > ?", end_time, start_time)
  }

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
  before_save :reset_status_if_details_changed
  after_commit :send_status_notifications, on: [ :create, :update ]
  after_commit :schedule_reminder_job, on: [ :create, :update ]

  def destroyable?
    blocked?
  end

  def status_text
    I18n.t("enums.reservation.status.#{status}", default: status.humanize)
  end

  def status_color_classes
    case status
    when "pending" then "bg-amber-50 text-amber-700 border-amber-100 dark:bg-amber-950/30 dark:text-amber-400 dark:border-amber-900/50"
    when "confirmed" then "bg-emerald-50 text-emerald-700 border-emerald-100 dark:bg-emerald-950/30 dark:text-emerald-400 dark:border-emerald-900/50"
    when "cancelled" then "bg-rose-50 text-rose-700 border-rose-100 dark:bg-rose-950/30 dark:text-rose-400 dark:border-rose-900/50"
    when "blocked" then "bg-slate-700 text-white border-slate-800 dark:bg-slate-800 dark:text-slate-200 dark:border-slate-700 shadow-sm"
    else "bg-gray-50 text-gray-700 border-gray-100 dark:bg-slate-800/50 dark:text-slate-400 dark:border-slate-700/50"
    end
  end

  def total_paid
    if payments.loaded?
      abonos = payments.select(&:abono?).sum(&:amount)
      reembolsos = payments.select(&:reembolso?).sum(&:amount)
      abonos - reembolsos
    else
      payments.abono.sum(:amount) - payments.reembolso.sum(:amount)
    end
  end

  def pending_balance
    (total_price || 0) - total_paid
  end

  def payment_state
    paid = total_paid
    if paid <= 0
      "No pagado"
    elsif paid < (total_price || 0)
      "Abonado"
    else
      "Pagado"
    end
  end

  def payment_state_color_classes
    case payment_state
    when "Pagado" then "bg-emerald-50 text-emerald-700 border-emerald-100 dark:bg-emerald-950/30 dark:text-emerald-400 dark:border-emerald-900/50"
    when "Abonado" then "bg-amber-50 text-amber-700 border-amber-100 dark:bg-amber-950/30 dark:text-amber-400 dark:border-amber-900/50"
    when "No pagado" then "bg-gray-50 text-gray-500 border-gray-100 dark:bg-slate-800/50 dark:text-slate-400 dark:border-slate-700/50"
    else "bg-gray-50 text-gray-500 border-gray-100 dark:bg-slate-800/50 dark:text-slate-400 dark:border-slate-700/50"
    end
  end

  def self.for_calendar(property_id: nil, start_date_str: nil, end_date_str: nil, exclude_id: nil)
    query = Reservation.active_and_valid.joins(:property).includes(:property)
    query = query.where(property_id: property_id) if property_id.present?

    if start_date_str.present? && end_date_str.present?
      start_date = Time.zone.parse(start_date_str) rescue nil
      end_date = Time.zone.parse(end_date_str) rescue nil
      if start_date && end_date
        query = query.overlapping_range(start_date, end_date)
      end
    end

    query = query.where.not(id: exclude_id) if exclude_id.present?
    query.order(start_time: :asc)
  end

  def confirm_by_client!
    return { status: :error, message: "Este enlace de confirmación ha expirado por seguridad (límite de 24 horas)." } if created_at < 24.hours.ago
    return { status: :info, message: "Esta reserva ya se encuentra confirmada." } if confirmed?
    return { status: :error, message: "No se puede confirmar una reserva que ya ha sido cancelada." } if cancelled?

    transaction do
      update!(status: :confirmed)
      Notification.create!(
        user: user,
        notifiable: self,
        message: "¡Reserva Confirmada! #{client_name} ha aceptado la reserva para #{property.name}."
      )
    end
    { status: :success, message: "¡Gracias! Tu reserva ha sido confirmada exitosamente." }
  end

  def reject_by_client!
    return { status: :error, message: "Este enlace ha expirado por seguridad (límite de 24 horas)." } if created_at < 24.hours.ago
    return { status: :info, message: "Esta reserva ya se encuentra cancelada." } if cancelled?

    transaction do
      self.skip_notifications = true
      update!(status: :cancelled)
      Notification.create!(
        user: user,
        notifiable: self,
        message: "Reserva Rechazada: #{client_name} ha cancelado la solicitud para #{property.name}."
      )
    end
    { status: :success, message: "La reserva ha sido rechazada y cancelada." }
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

    scope = property.reservations.where.not(id: id).active_and_valid

    if property.per_day?
      overlapping = scope.where("CAST(start_time AS DATE) < CAST(? AS DATE) AND CAST(end_time AS DATE) > CAST(? AS DATE)",
                                end_time, start_time).first
    else
      overlapping = scope.overlapping_range(start_time, end_time).first
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

  def reset_status_if_details_changed
    return if status_changed?
    return unless confirmed?

    if start_time_changed? || end_time_changed?
      self.status = :pending
    end
  end

  def send_status_notifications
    return if skip_notifications
    return unless saved_change_to_status? || saved_change_to_id? || saved_change_to_start_time? ||
                  saved_change_to_end_time? || saved_change_to_client_id?
    return if client.blank? || client.email.blank? || blocked?

    case status
    when "pending"
      is_public = !!Thread.current[:created_by_public]
      ReservationMailer.pending_confirmation(self, created_by_public: is_public).deliver_later
    when "confirmed"
      ReservationMailer.confirmed(self).deliver_later
    when "cancelled"
      ReservationMailer.cancelled(self).deliver_later
    end
  end

  def schedule_reminder_job
    return unless confirmed? && !blocked?
    return if start_time < 24.hours.from_now
    return unless saved_change_to_start_time? || saved_change_to_status?

    ReservationReminderJob.set(wait_until: start_time - 24.hours).perform_later(self, start_time)
  end
end
