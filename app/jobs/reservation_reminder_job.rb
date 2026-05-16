class ReservationReminderJob < ApplicationJob
  queue_as :default

  # expected_start_time is passed at enqueue time so that if the reservation's
  # start_time changes later (which enqueues a new job), older stale jobs
  # detect the mismatch and exit early — avoiding duplicate reminder emails.
  def perform(reservation, expected_start_time)
    return if reservation.blank?
    return unless reservation.confirmed? && !reservation.blocked?
    return if reservation.start_time != expected_start_time

    ReservationMailer.reminder(reservation).deliver_now
  end
end
