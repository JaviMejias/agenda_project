class ReservationReminderJob < ApplicationJob
  queue_as :default

  def perform(reservation)
    return if reservation.blank?
    return unless reservation.confirmed?

    window_start = reservation.start_time - 24.hours - 5.minutes
    window_end = reservation.start_time - 24.hours + 5.minutes

    if Time.zone.now.between?(window_start, window_end)
      ReservationMailer.reminder(reservation).deliver_now
    end
  end
end
