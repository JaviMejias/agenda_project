class Expense < ApplicationRecord
  belongs_to :property
  has_many_attached :vouchers

  enum :category, { light: 0, water: 1, cleaning: 2, maintenance: 3, other: 4 }

  def self.translated_categories
    {
      "light" => "Luz",
      "water" => "Agua",
      "cleaning" => "Limpieza",
      "maintenance" => "Mantenimiento",
      "other" => "Otros"
    }
  end

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expense_date, presence: true
end
