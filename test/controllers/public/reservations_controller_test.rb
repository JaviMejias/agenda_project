require "test_helper"

class Public::ReservationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Use reservation 'two' which is pending (status 0)
    @reservation = reservations(:two)
    @reservation.update!(token: "token123", created_at: Time.zone.now)
  end

  test "should confirm reservation with valid token" do
    get confirm_public_reservation_url(token: "token123")
    assert_response :success
    assert_match "confirmada exitosamente", response.body
    @reservation.reload
    assert @reservation.confirmed?
  end

  test "should reject reservation with valid token" do
    get reject_public_reservation_url(token: "token123")
    assert_response :success
    assert_match "cancelada", response.body
    @reservation.reload
    assert @reservation.cancelled?
  end

  test "should show reservation with token" do
    get public_reservation_url(token: "token123")
    assert_response :success
    assert_match "Estado de tu Reserva", response.body
  end

  test "should get public receipt PDF" do
    get receipt_public_reservation_url(token: "token123", format: :pdf)
    assert_response :success
    assert_equal "application/pdf", response.headers["Content-Type"]
  end

  test "should create public reservation as guest" do
    property = properties(:one)
    assert_difference("Reservation.count") do
      assert_difference("Client.count") do
        post public_property_public_reservations_url(property), params: {
          client_name: "John Doe",
          client_email: "john@example.com",
          client_phone: "+56 9 8765 4321",
          client_rut: "19.456.789-8",
          reservation: {
            start_time: 4.days.from_now.change(hour: 10).iso8601,
            end_time: 5.days.from_now.change(hour: 10).iso8601
          }
        }
      end
    end
    new_res = Reservation.last
    assert_redirected_to public_reservation_url(new_res.token)
    assert new_res.pending?
  end

  test "should add payment to reservation" do
    assert_difference("Payment.count") do
      post add_payment_public_reservation_url(token: "token123"), params: {
        payment: {
          amount: "15000",
          operation_number: "987654",
          notes: "Abono de prueba"
        }
      }
    end
    assert_redirected_to public_reservation_url("token123")
  end

  test "should not confirm expired reservation" do
    @reservation.update_columns(created_at: 25.hours.ago, updated_at: 25.hours.ago)
    get confirm_public_reservation_url(token: "token123")
    assert_response :success
    assert_match "ha expirado", response.body
    assert_not @reservation.reload.confirmed?
  end

  test "should redirect to search for invalid token on html request" do
    get confirm_public_reservation_url(token: "invalid")
    assert_redirected_to search_public_reservations_url
    follow_redirect!
    assert_match "El código de reserva no es válido", response.body
  end

  test "should get search page" do
    get search_public_reservations_url
    assert_response :success
    assert_match "Sigue tu Reserva", response.body
  end

  test "should redirect to reservation show when valid token is searched" do
    get search_public_reservations_url, params: { token: "token123" }
    assert_redirected_to public_reservation_url("token123")
  end

  test "should show alert on search page when invalid token is searched" do
    get search_public_reservations_url, params: { token: "invalid" }
    assert_response :success
    assert_match "El código ingresado no corresponde a ninguna reserva activa", response.body
  end

  test "should delete payment from reservation" do
    payment = payments(:one)
    payment.update!(reservation_id: @reservation.id)

    assert_difference("Payment.count", -1) do
      delete delete_payment_public_reservation_url(token: "token123", payment_id: payment.id)
    end
    assert_redirected_to public_reservation_url("token123")
  end

  test "should not add payment if already fully paid" do
    @reservation.payments.destroy_all
    @reservation.payments.create!(amount: @reservation.total_price, payment_method: :transfer, transaction_type: :abono, payment_date: Time.current)

    assert_no_difference("Payment.count") do
      post add_payment_public_reservation_url(token: "token123"), params: {
        payment: {
          amount: "5000",
          operation_number: "111",
          notes: "Extra pay"
        }
      }
    end
    assert_redirected_to public_reservation_url("token123")
    follow_redirect!
    assert_match "ya se encuentra totalmente pagada", response.body
  end

  test "should upload missing voucher to payment" do
    payment = payments(:one)
    payment.update!(reservation_id: @reservation.id, payment_method: :transfer)
    payment.voucher.purge if payment.voucher.attached?
    assert_not payment.voucher.attached?

    uploaded_file = fixture_file_upload("dummy.png", "image/png")

    post upload_voucher_public_reservation_url(token: "token123", payment_id: payment.id), params: {
      payment: {
        voucher: uploaded_file
      }
    }

    assert_redirected_to public_reservation_url("token123")
    payment.reload
    assert payment.voucher.attached?
  end
end
