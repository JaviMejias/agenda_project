require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "should get index" do
    get reports_url
    assert_response :success
  end

  test "should get index with dates" do
    get reports_url, params: { start_date: 1.month.ago.to_date, end_date: Date.today }
    assert_response :success
  end
end
