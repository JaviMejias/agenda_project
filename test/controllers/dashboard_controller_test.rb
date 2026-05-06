require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "should get index" do
    get dashboard_url
    assert_response :success
  end
end
