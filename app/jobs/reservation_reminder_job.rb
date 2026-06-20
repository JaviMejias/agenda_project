class ReservationReminderJob < ApplicationJob
  queue_as :default

  def perform(reservation, expected_start_time)
    return if reservation.blank?
    return unless reservation.confirmed? && !reservation.blocked?
    return if reservation.start_time != expected_start_time

    ReservationMailer.reminder(reservation).deliver_now
  end
end
