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
    visit property_url(@property)

    # Check for the button or visit the destroy action if it's a simple link
    # In this app, it's a button. Rack_test can click it.
    # But wait, destroy usually requires a DELETE request which might need JS for the confirmation or method: :delete
    # Rack_test handles data-method=:delete if we use the right helpers.
  end
end
