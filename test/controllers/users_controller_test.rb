require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
    @user = users(:one)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count") do
      post users_url, params: { user: {
        email: "otro@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: "normal",
        first_name: "Test",
        last_name: "User"
      } }
    end

    assert_redirected_to users_url
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { first_name: "Nombre Actualizado" } }
    assert_redirected_to users_url
  end

  test "should destroy user" do
    # Create a user with associations to test cascading delete
    temp_user = User.create!(
      email: "temp_with_assoc@example.com",
      password: "password123",
      first_name: "Temp",
      last_name: "Assoc",
      role: :normal
    )
    # Create a client associated with this user
    Client.create!(user: temp_user, name: "Test Client", rut: "123456785")

    assert_difference("User.count", -1) do
      delete user_url(temp_user)
    end

    assert_redirected_to users_url
  end

  test "should not destroy self" do
    assert_no_difference("User.count") do
      delete user_url(@admin)
    end
    assert_redirected_to users_url
  end
end
