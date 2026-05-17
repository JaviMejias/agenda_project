require "test_helper"

class Public::MyReservationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @client_user = users(:one)
    @client_user.update!(role: :client) # force client role
    
    @owner_user = users(:admin)
    @owner_user.update!(role: :normal) # force normal/owner role for test

    @reservation = reservations(:one)
    @client = clients(:one)
    
    # Link reservation to the client email matching client_user
    @client.update!(email: @client_user.email)
    @reservation.update!(client: @client)
  end

  test "should get index for logged-in client" do
    sign_in @client_user
    get my_reservations_url
    assert_response :success
    assert_match "Mis Reservas", response.body
    assert_match @reservation.property.name, response.body
  end

  test "should redirect normal user trying to access client reservations" do
    sign_in @owner_user
    get my_reservations_url
    assert_redirected_to dashboard_url
    assert_equal "Esta sección es exclusiva para clientes.", flash[:alert]
  end

  test "should redirect unauthenticated user to sign in" do
    get my_reservations_url
    assert_redirected_to new_user_session_url
  end
end
