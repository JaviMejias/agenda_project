require "test_helper"

class DashboardStatsServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @range = 1.month.ago..1.month.from_now
    @service = DashboardStatsService.new(@user, @range)
  end

  test "should calculate correct stats" do
    stats = @service.stats

    assert_respond_to stats, :[]
    assert stats.key?(:completed_revenue)
    assert stats.key?(:projected_revenue)
    assert stats.key?(:pending_count)
    assert stats.key?(:total_count)

    expected_pending = @user.reservations.in_range(@range).pending.count
    assert_equal expected_pending, stats[:pending_count]
  end

  test "should filter by company if provided" do
    company = Company.create!(
      name: "Test Co",
      user: @user,
      rut: "123456785",
      address: "Address",
      business_type: "Type"
    )
    property = properties(:one)
    property.update!(company: company)

    service = DashboardStatsService.new(@user, @range, company_id: company.id)
    stats = service.stats

    assert stats.key?(:revenue_by_property)
  end
end
