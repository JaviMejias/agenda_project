require "test_helper"

class ReservationMailerTest < ActionMailer::TestCase
  def setup
    @reservation = reservations(:one)
    # Ensure token is present for URL generation in templates
    @reservation.token ||= SecureRandom.hex(10)
  end

  test "confirmed" do
    mail = ReservationMailer.confirmed(@reservation)
    assert_match /Confirmación/, mail.subject
    assert_equal [ @reservation.client.email ], mail.to
    assert_match @reservation.client_name, mail.body.encoded
  end

  test "cancelled" do
    mail = ReservationMailer.cancelled(@reservation)
    assert_match /Cancelación/, mail.subject
    assert_equal [ @reservation.client.email ], mail.to
    assert_match @reservation.client_name, mail.body.encoded
  end
end
