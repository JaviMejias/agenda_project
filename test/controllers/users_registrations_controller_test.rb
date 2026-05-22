require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new registration" do
    get new_user_registration_url
    assert_response :success
  end

  test "should register new user with valid parameters" do
    assert_difference("User.count") do
      post user_registration_url, params: {
        user: {
          first_name: "Diego",
          last_name: "Pérez",
          email: "diegoperez@example.com",
          password: "password123",
          password_confirmation: "password123",
          rut: "12345678-5",
          phone: "+56912345678"
        }
      }
    end
    assert_redirected_to root_url
    assert User.last.client? # ensure automagic client role assignment
  end

  test "should render errors when registering with invalid parameters" do
    assert_no_difference("User.count") do
      post user_registration_url, params: {
        user: {
          first_name: "",
          last_name: "",
          email: "invalid-email",
          password: "123",
          password_confirmation: "1234"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_match "errores impidieron", response.body
  end
end
