require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user = users(:one)
    sign_in @user
    @client = clients(:one)
  end

  test "should get index" do
    get clients_url
    assert_response :success
  end

  test "should get show" do
    get client_url(@client)
    assert_response :success
  end

  test "should get new" do
    get new_client_url
    assert_response :success
  end

  test "should create client" do
    assert_difference("Client.count") do
      post clients_url, params: { client: {
        name: "Nuevo Cliente",
        rut: "151473210",
        email: "nuevo_test_final_final@example.com",
        phone: "123"
      } }
    end
    assert_redirected_to clients_url
  end

  test "should get edit" do
    get edit_client_url(@client)
    assert_response :success
  end

  test "should update client" do
    # Now that fixtures have valid RUTs, this should work
    patch client_url(@client), params: { client: { name: "Nombre Editado" } }
    assert_redirected_to clients_url
  end

  test "should destroy client" do
    sign_out @user
    sign_in @admin

    assert_difference("Client.count", -1) do
      delete client_url(@client)
    end
    assert_redirected_to clients_url
  end
end
