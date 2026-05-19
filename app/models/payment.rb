class Payment < ApplicationRecord
  belongs_to :reservation
  has_one_attached :voucher

  attr_accessor :purge_voucher

  enum :status, { pending: 0, approved: 1, rejected: 2 }
  enum :payment_method, { transfer: 0, cash: 1, card: 2, other: 3 }
  enum :transaction_type, { abono: 0, reembolso: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true

  before_validation :auto_approve_non_transfers
  before_validation :purge_voucher_if_requested
  before_save :clean_operation_data

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
      voucher.purge if voucher.attached?
      self.operation_number = nil
    end
  end
end
