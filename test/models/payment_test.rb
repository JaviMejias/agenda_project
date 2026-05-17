require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @payment = payments(:one)
  end

  test "should be valid" do
    assert @payment.valid?
  end

  test "should require amount" do
    @payment.amount = nil
    assert_not @payment.valid?
  end

  test "should require numerical amount greater than 0" do
    @payment.amount = 0
    assert_not @payment.valid?
  end

  test "should require payment_date" do
    @payment.payment_date = nil
    assert_not @payment.valid?
  end

  test "should clean operation data for cash or card" do
    @payment.payment_method = "cash"
    @payment.operation_number = "123456"
    @payment.save
    assert_nil @payment.operation_number
  end

  test "should purge voucher when requested" do
    # Set to transfer since cash/card automatically purge any attached voucher
    @payment.payment_method = "transfer"
    @payment.save!

    @payment.voucher.attach(
      io: StringIO.new("dummy"),
      filename: "dummy.png",
      content_type: "image/png"
    )
    assert @payment.voucher.attached?

    @payment.purge_voucher = "1"

    perform_enqueued_jobs do
      @payment.save!
    end

    assert_not @payment.reload.voucher.attached?
  end
end
