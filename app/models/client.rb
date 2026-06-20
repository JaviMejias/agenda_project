class Client < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :nullify

  include RutValidatable
  validates_rut :rut

  enum :tag, { unassigned: 0, vip: 1, recurrent: 2, conflictive: 3 }

  validates :name, presence: true
  validates :rut, presence: true, uniqueness: { scope: :user_id }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :search, ->(query) {
    if query.present?
      where("name ILIKE ? OR rut ILIKE ? OR email ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
    else
      all
    end
  }

  def display_name
    "#{name} (#{formatted_rut})"
  end

  def total_spent
    reservations.sum(:total_price).to_i
  end

  def reservations_count
    reservations.count
  end
end
