require "application_system_test_case"

class PropertiesTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin)
    login_as_user(@admin)
    @property = properties(:one)
  end

  test "visiting the index" do
    visit properties_url
    assert_text "Mis Propiedades"
  end

  test "should create property" do
    visit properties_url
    click_on "Nueva Propiedad"

    fill_in "property[name]", with: "Nueva Propiedad de Prueba"
    fill_in "property[address]", with: "Calle Falsa 123"
    fill_in "property[base_price]", with: 25000
    select "Por Día", from: "property[pricing_model]"

    click_on "Guardar Propiedad"

    assert_text "Propiedad creada exitosamente"
  end

  test "should update Property" do
    visit property_url(@property)
    # The "Editar" button is in a specific link
    visit edit_property_url(@property)

    fill_in "property[name]", with: "Nombre Editado"
    click_on "Guardar Propiedad"

    assert_text "Propiedad creada correctamente"
  end

  test "should destroy Property" do
    property = Property.create!(name: "To be destroyed", base_price: 100, user: @admin)
    visit property_url(property)

    click_on "Eliminar Propiedad"

    assert_text "Propiedad eliminada correctamente."
  end
end
