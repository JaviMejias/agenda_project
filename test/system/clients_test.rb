require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as_user(@user)
    @client = clients(:one)
  end

  test "visiting the index" do
    visit clients_url
    assert_text "Base de Clientes"
  end

  test "should create client" do
    visit clients_url
    click_on "Nuevo Cliente"

    fill_in "client[name]", with: "Nuevo Cliente Sistema"
    # 15147321-0 is valid
    fill_in "client[rut]", with: "151473210"
    fill_in "client[email]", with: "sistema_nuevo@example.com"

    click_on "Guardar Cliente"

    assert_text "Cliente creado exitosamente"
  end
end
