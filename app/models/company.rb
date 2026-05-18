class Company < ApplicationRecord
  belongs_to :user
  has_many :properties, dependent: :nullify
  has_many :bank_accounts, dependent: :destroy
  has_one_attached :logo

  accepts_nested_attributes_for :bank_accounts, allow_destroy: true, reject_if: :all_blank

  include RutValidatable
  validates_rut :rut

  validates :name, :business_type, :address, presence: true
  validates :rut, presence: true, uniqueness: { scope: :user_id }

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

  def associate_properties(property_ids)
    return false if property_ids.blank?
    Property.where(id: property_ids, user_id: user_id).update_all(company_id: id)
  end
end
