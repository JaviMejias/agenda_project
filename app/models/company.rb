class Company < ApplicationRecord
  belongs_to :user
  has_many :properties, dependent: :nullify

  include RutValidatable

  validates :name, presence: true
  validates :rut, presence: true, uniqueness: { scope: :user_id }
  validates :address, presence: true
  validates :business_type, presence: true

  scope :search, ->(query) {
    if query.present?
      where("name ILIKE ? OR rut ILIKE ?", "%#{query}%", "%#{query}%")
    else
      all
    end
  }

  def self.ordered
    order(name: :asc)
  end
end
