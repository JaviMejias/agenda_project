class Payment < ApplicationRecord
  belongs_to :reservation
  has_one_attached :voucher

  attr_accessor :purge_voucher

  enum :payment_method, { transfer: 0, cash: 1, card: 2, other: 3 }
  enum :transaction_type, { abono: 0, reembolso: 1 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true

  before_validation :purge_voucher_if_requested
  before_save :clean_operation_data

  private

  def purge_voucher_if_requested
    if purge_voucher == "1" || purge_voucher == true
      voucher.purge_later
    end
  end

  def clean_operation_data
    if cash? || card?
      voucher.purge if voucher.attached?
      self.operation_number = nil
    end
  end
end
