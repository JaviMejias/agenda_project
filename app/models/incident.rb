class Incident < ApplicationRecord
  belongs_to :property
  belongs_to :reservation, optional: true

  has_one_attached :photo

  enum :status, { pending: 0, in_progress: 1, resolved: 2 }
  enum :severity, { low: 0, medium: 1, high: 2 }

  validates :title, presence: true
  validates :description, presence: true
end
