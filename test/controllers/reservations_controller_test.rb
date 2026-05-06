require "test_helper"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
    @reservation = reservations(:one)
    @property = properties(:one)
  end

  test "should get index" do
    get reservations_url
    assert_response :success
  end

  test "should get list" do
    get list_reservations_url
    assert_response :success
  end

  test "should get new" do
    get new_property_reservation_url(@property)
    assert_response :success
  end

  test "should create reservation" do
    assert_difference("Reservation.count") do
      post property_reservations_url(@property), params: {
        reservation: {
          client_name: "Nuevo Cliente",
          start_time: 10.days.from_now,
          end_time: 11.days.from_now,
          status: :pending
        }
      }
    end

    assert_redirected_to property_path(@property)
  end

  test "should show reservation" do
    get reservation_url(@reservation)
    assert_response :success
  end

  test "should get edit" do
    get edit_reservation_url(@reservation)
    assert_response :success
  end

  test "should update reservation" do
    patch reservation_url(@reservation), params: {
      reservation: {
        client_name: "Nombre Actualizado"
      }
    }
    assert_redirected_to reservations_url
  end

  test "should destroy reservation" do
    # Create a destroyable (blocked) reservation
    blocked_reservation = Reservation.create!(
      property: @property,
      user: @admin,
      start_time: 20.days.from_now,
      end_time: 21.days.from_now,
      status: :blocked
    )

    assert_difference("Reservation.count", -1) do
      delete reservation_url(blocked_reservation)
    end

    assert_redirected_to reservations_url
  end
end
