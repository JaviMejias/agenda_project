class Property < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  has_many :reservations, dependent: :destroy
  has_many_attached :images

  enum :pricing_model, { per_day: 0, per_hour: 1 }

  validates :name, presence: true
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") if query.present? }

  def pricing_model_text
    per_day? ? "Por Día" : "Por Hora"
  end

  def cover_image
    images.first
  end

  def thumbnail(image)
    image.variant(resize_to_limit: [200, 200])
  end

  def gallery_variant(image)
    image.variant(resize_to_limit: [800, 600])
  end

  def carousel_variant(image)
    image.variant(resize_to_limit: [400, 300])
  end
end
