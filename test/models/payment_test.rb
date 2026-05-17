require "test_helper"

class PaymentTest < ActiveSupport::TestCase
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
end
