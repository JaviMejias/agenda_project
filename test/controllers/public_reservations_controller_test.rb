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
