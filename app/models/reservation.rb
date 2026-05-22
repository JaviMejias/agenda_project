class Reservation < ApplicationRecord
  belongs_to :property
  belongs_to :user
  belongs_to :client, optional: true
  has_many :payments, dependent: :destroy
  has_many :reservation_audits, dependent: :destroy

  attr_accessor :skip_notifications, :audit_author_name

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
         .where.not("reservations.status = ? AND COALESCE(reservations.pending_status_set_at, reservations.updated_at) < ?", Reservation.statuses[:pending], 24.hours.ago)
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
      joins(:property).where(
        "client_name ILIKE :q OR properties.name ILIKE :q OR reservations.token ILIKE :q",
        q: "%#{query}%"
      )
    else
      joins(:property)
    end
  }
  scope :ordered, -> { order(start_time: :desc) }

  scope :for_list, ->(query: nil, status: nil) {
    list = includes(:property, :payments, :user).search(query).ordered
    list = list.where(status: status) if status.present?
    list
  }

  before_validation :sync_client_name
  before_validation :handle_blocked_reservation
  before_save :calculate_total_price
  before_save :reset_status_if_details_changed
  before_save :set_pending_status_timestamp
  after_commit :send_status_notifications, on: [ :create, :update ]
  after_commit :schedule_reminder_job, on: [ :create, :update ]
  after_commit :create_audit_log, on: [ :create, :update ]

  def destroyable?
    blocked?
  end

  def status_text
    I18n.t("enums.reservation.status.#{status}", default: status.humanize)
  end


  def total_paid
    if payments.loaded?
      approved_payments = payments.select(&:approved?)
      abonos = approved_payments.select(&:abono?).sum(&:amount)
      reembolsos = approved_payments.select(&:reembolso?).sum(&:amount)
      abonos - reembolsos
    else
      payments.approved.abono.sum(:amount) - payments.approved.reembolso.sum(:amount)
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


  def self.for_calendar(property_id: nil, start_date_str: nil, end_date_str: nil, exclude_id: nil)
    query = all.active_and_valid.joins(:property).includes(:property, :payments)
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
      client_display = overlapping.blocked? ? "BLOQUEO DE FECHA" : "#{overlapping.client_name}"

      message = "La propiedad ya está #{overlapping.blocked? ? 'bloqueada' : 'reservada'} en estas fechas por " \
                "#{client_display}, desde el " \
                "#{overlapping.start_time.strftime(format)} al " \
                "#{overlapping.property.per_day? ? (overlapping.end_time - 1.day).strftime(format) : overlapping.end_time.strftime(format)} " \
                "(Ref: #{overlapping.id})."
      errors.add(:base, message)
      errors.add(:overlapping_id, overlapping.id) if errors.respond_to?(:add)
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

  def set_pending_status_timestamp
    if status == "pending" && (new_record? || status_changed?)
      self.pending_status_set_at = Time.current
    end
  end

  def send_status_notifications
    return if skip_notifications
    return unless saved_change_to_status? || saved_change_to_id? || saved_change_to_start_time? ||
                  saved_change_to_end_time? || saved_change_to_client_id?
    return if client.blank? || client.email.blank? || blocked?

    case status
    when "pending"
      is_public = !!Current.created_by_public
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

  def create_audit_log
    changes = saved_changes.except("updated_at", "created_at", "token", "pending_status_set_at")
    return if changes.empty? && !id_previously_changed?

    action_name = id_previously_changed? ? "creación" : "actualización"
    if saved_change_to_status?
      action_name = status
    end

    # Evitamos registrar duplicados si el servicio ya registró
    return if @audit_manually_created

    reservation_audits.create!(
      user_id: Current.user&.id,
      author_name: audit_author_name || (Current.user ? nil : "Sistema / Externo"),
      action: action_name,
      details: changes
    )
  end
end
