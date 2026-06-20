class Property < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  has_many :reservations, dependent: :restrict_with_error
  has_many :expenses, dependent: :destroy
  has_many :incidents, dependent: :destroy
  has_many_attached :images

  enum :pricing_model, { per_day: 0, per_hour: 1 }

  validates :name, presence: true
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") if query.present? }
  scope :search_public, ->(query) {
    if query.present?
      where("name LIKE :q OR address LIKE :q OR description LIKE :q", q: "%#{query}%")
    end
  }
  scope :by_pricing_model, ->(model) { where(pricing_model: model) if model.present? }
  scope :available_for_selector, ->(user, query: nil) {
    base = user.admin? ? all : user.properties
    base = base.search(query) if query.present?
    base.where(company_id: [ nil, "" ]).limit(20)
  }

  def pricing_model_text
    per_day? ? "Por Día" : "Por Hora"
  end

  def cover_image
    images.first
  end

  def thumbnail(image)
    image.variant(resize_to_limit: [ 200, 200 ])
  end

  def gallery_variant(image)
    image.variant(resize_to_limit: [ 800, 600 ])
  end

  def carousel_variant(image)
    image.variant(resize_to_limit: [ 800, 600 ])
  end
end
