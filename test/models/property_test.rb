require "test_helper"

class PropertyTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should be valid with correct attributes" do
    property = Property.new(
      name: "Nueva Propiedad",
      base_price: 1000,
      user: @user
    )
    assert property.valid?
  end

  test "should be invalid without name" do
    property = Property.new(name: nil)
    assert_not property.valid?
    assert_includes property.errors[:name], "es obligatorio/a"
  end

  test "should be invalid with negative base_price" do
    property = Property.new(base_price: -10)
    assert_not property.valid?
    # Match the actual error message "debe ser mayor que o igual a 0"
    assert_includes property.errors[:base_price], "debe ser mayor que o igual a 0"
  end

  test "pricing_model_text should return correct translation" do
    per_day = properties(:one)
    per_hour = properties(:two)

    assert_equal "Por Día", per_day.pricing_model_text
    assert_equal "Por Hora", per_hour.pricing_model_text
  end

  test "search scope should find property by name" do
    results = Property.search("Campo")
    assert_includes results, properties(:one)
    assert_not_includes results, properties(:two)
  end
end
