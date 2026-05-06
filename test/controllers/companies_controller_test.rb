require "test_helper"

class CompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
    @company = companies(:one)
  end

  test "should get index" do
    get companies_url
    assert_response :success
  end

  test "should get new" do
    get new_company_url
    assert_response :success
  end

  test "should create company" do
    # Use a unique and valid RUT
    assert_difference("Company.count") do
      post companies_url, params: { company: {
        name: "Empresa Unica",
        rut: "186365291",
        address: "Direccion 123",
        business_type: "Giro"
      } }
    end

    assert_redirected_to companies_url
  end

  test "should show company" do
    get company_url(@company)
    assert_response :success
  end

  test "should get edit" do
    get edit_company_url(@company)
    assert_response :success
  end

  test "should update company" do
    patch company_url(@company), params: { company: { name: "Nombre Actualizado" } }
    assert_redirected_to companies_path
  end

  test "should destroy company" do
    assert_difference("Company.count", -1) do
      delete company_url(@company)
    end

    assert_redirected_to companies_path
  end

  test "should associate properties" do
    property = properties(:one)
    post associate_properties_company_url(@company), params: { property_ids: [ property.id ] }
    assert_redirected_to @company
    assert_equal @company.id, property.reload.company_id
  end
end
