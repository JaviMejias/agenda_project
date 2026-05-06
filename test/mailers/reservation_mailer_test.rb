require "test_helper"

class ReservationMailerTest < ActionMailer::TestCase
  test "confirmed" do
    mail = ReservationMailer.confirmed
    assert_equal "Confirmed", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "cancelled" do
    mail = ReservationMailer.cancelled
    assert_equal "Cancelled", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
