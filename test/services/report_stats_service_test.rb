require "test_helper"

class ReportStatsServiceTest < ActiveSupport::TestCase
  def setup
    @start_date = 1.month.ago.to_date
    @end_date = 1.month.from_now.to_date
    @service = ReportStatsService.new(@start_date, @end_date)
  end

  test "should calculate correct income" do
    stats = @service.stats

    assert stats.key?(:total_income)
    assert stats.key?(:total_loss)
    assert stats.key?(:properties_data)

    expected_income = Reservation.confirmed.in_range(@start_date.beginning_of_day..@end_date.end_of_day).sum(:total_price)
    assert_equal expected_income, stats[:total_income]
  end

  test "should include monthly trend" do
    stats = @service.stats
    assert stats.key?(:monthly_trend)
    assert_equal 6, stats[:monthly_trend].length
  end
end
