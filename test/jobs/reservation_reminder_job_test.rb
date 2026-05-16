require "test_helper"

class ReservationReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  def setup
    @reservation = reservations(:one)
    # Ensure token for URL generation
    @reservation.update!(token: SecureRandom.hex(10))
  end

  test "should deliver reminder when in window" do
    reference_time = Time.zone.parse("2026-06-01 10:00:00")
    travel_to reference_time do
      start = 24.hours.from_now
      @reservation.update!(start_time: start, end_time: start + 2.hours)
      @reservation.update_column(:status, :confirmed) # Force confirmed status

      assert_emails 1 do
        ReservationReminderJob.perform_now(@reservation, @reservation.start_time)
      end
    end
  end

  test "should not deliver reminder when outside window" do
    start = 48.hours.from_now
    @reservation.update!(start_time: start, end_time: start + 2.hours)

    assert_emails 0 do
      ReservationReminderJob.perform_now(@reservation, @reservation.start_time)
    end
  end

  test "should not deliver if reservation is not confirmed" do
    start = 24.hours.from_now
    @reservation.update!(start_time: start, end_time: start + 2.hours, status: :pending)

    assert_emails 0 do
      ReservationReminderJob.perform_now(@reservation, @reservation.start_time)
    end
  end
end
