class Payment < ApplicationRecord
  belongs_to :reservation
  has_one_attached :voucher

  attr_accessor :purge_voucher

  enum :status, { pending: 0, approved: 1, rejected: 2 }

  attr_accessor :audit_author_name
  enum :payment_method, { transfer: 0, cash: 1, card: 2, other: 3 }
  enum :transaction_type, { abono: 0, reembolso: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true

  before_validation :auto_approve_non_transfers
  before_validation :purge_voucher_if_requested
  before_save :clean_operation_data
  after_commit :create_reservation_audit_log, on: [ :create, :update, :destroy ]

  def notify_admin_of_new_payment!
    Notification.create!(
      user: reservation.user,
      notifiable: self,
      message: "¡Nuevo Comprobante! #{reservation.client_name} ha subido un comprobante de pago para la reserva ##{reservation.id}."
    )
  end

  def notify_admin_of_updated_voucher!
    Notification.create!(
      user: reservation.user,
      notifiable: self,
      message: "¡Comprobante Actualizado! #{reservation.client_name} ha cargado el comprobante para el pago de $#{amount.to_i} en la reserva ##{reservation.id}."
    )
  end

  private

  def purge_voucher_if_requested
    if purge_voucher == "1" || purge_voucher == true
      voucher.purge_later
    end
  end

  def auto_approve_non_transfers
    self.status = :approved if cash? || card?
  end

  def clean_operation_data
    if cash? || card?
      voucher.purge_later if voucher.attached?
      self.operation_number = nil
    end
  end

  def create_reservation_audit_log
    if !id_previously_changed? && !destroyed?
      relevant_changes = saved_changes.except("updated_at")
      return if relevant_changes.empty?
    end

    action_name = "payment_added"   if id_previously_changed?
    action_name ||= "payment_deleted" if destroyed?

    if !action_name && saved_change_to_status?
      action_name = "payment_#{status}"
    end

    action_name ||= "payment_updated"

    details = if action_name == "payment_updated"
      saved_changes
        .except("updated_at", "reservation_id")
        .transform_values { |change| change } # [antes, despues]
        .merge(payment_id: id)
    else
      { payment_id: id, amount: amount, method: payment_method, type: transaction_type }
    end

    reservation.reservation_audits.create!(
      user_id: Current.user&.id,
      author_name: audit_author_name || (Current.user ? nil : "Sistema / Externo"),
      action: action_name,
      details: details
    )
  end
end
