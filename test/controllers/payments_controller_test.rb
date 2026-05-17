require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @reservation = reservations(:one)
    @payment = payments(:one)
    sign_in @user
  end

  test "should get new" do
    get new_reservation_payment_url(@reservation)
    assert_response :success
  end

  test "should create payment" do
    assert_difference("Payment.count") do
      post reservation_payments_url(@reservation), params: { 
        payment: { 
          amount: 10000, 
          payment_date: Time.current, 
          payment_method: "transfer", 
          transaction_type: "abono" 
        } 
      }
    end

    assert_redirected_to reservation_url(@reservation)
  end

  test "should get edit" do
    get edit_reservation_payment_url(@reservation, @payment)
    assert_response :success
  end

  test "should update payment" do
    patch reservation_payment_url(@reservation, @payment), params: { 
      payment: { amount: 15000 } 
    }
    assert_redirected_to reservation_url(@reservation)
    @payment.reload
    assert_equal 15000, @payment.amount
  end

  test "should destroy payment" do
    assert_difference("Payment.count", -1) do
      delete reservation_payment_url(@reservation, @payment)
    end

    assert_redirected_to reservation_url(@reservation)
  end
end
