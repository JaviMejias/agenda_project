require "test_helper"

class PublicReservationsControllerTest < ActionDispatch::IntegrationTest
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
    @reservation.update!(created_at: 25.hours.ago)
    get confirm_public_reservation_url(token: "token123")
    assert_response :success
    assert_match "ha expirado", response.body
    assert_not @reservation.reload.confirmed?
  end

  test "should return 404 for invalid token" do
    get confirm_public_reservation_url(token: "invalid")
    assert_response :not_found
    assert_match "Reserva no encontrada", response.body
  end
end
