class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :validatable

  validates :first_name, presence: true
  validates :last_name, presence: true

  enum :role, { normal: 0, admin: 1 }

  scope :search, ->(query) {
    if query.present?
      where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
    else
      all
    end
  }
  scope :ordered, -> { order(created_at: :desc) }

  has_many :properties, dependent: :destroy
  has_many :companies, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :reservations_through_properties, through: :properties, source: :reservations

  before_validation :sync_password_confirmation

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def sync_password_confirmation
    if password.present?
      self.password_confirmation = password
    end
  end
end
