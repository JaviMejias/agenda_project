class ReservationAudit < ApplicationRecord
  belongs_to :reservation
  belongs_to :user, optional: true

  validates :action, presence: true
end
