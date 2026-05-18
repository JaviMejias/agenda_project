class Client < ApplicationRecord
  belongs_to :user
  has_many :reservations, dependent: :nullify

  include RutValidatable
  validates_rut :rut

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
end
