require "application_system_test_case"

class ReservationsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    login_as_user(@user)
    @reservation = reservations(:one)
    @property = properties(:one)
  end

  test "visiting the index" do
    visit reservations_url
    assert_text "Agenda de Reservas"
  end

  test "visiting a property agenda" do
    visit property_url(@property)
    assert_text @property.name
    # Property show doesn't have "Agenda de Reservas" text in a H1/H3, but "Ver Agenda de Reservas" in link
    assert_text "Nueva Reserva"
  end

  test "visiting the list of reservations" do
    visit list_reservations_url
    assert_text "Listado de Reservas"
  end
end
