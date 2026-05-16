class DashboardController < ApplicationController
  include DateRangeParams
  before_action :parse_date_range

  def index
    authorize :dashboard, :index?

    @stats             = DashboardStatsService.new(current_user, @range, company_id: @company_id).stats
    @completed_revenue = @stats[:completed_revenue]
    @projected_revenue = @stats[:projected_revenue]
    @actual_cash_in    = @stats[:actual_cash_in] || 0
    @total_expenses    = @stats[:total_expenses] || 0
    @pending_count     = @stats[:pending_count]
    @total_count       = @stats[:total_count]
    @status_counts     = @stats[:status_counts]
    @chart_labels      = @stats.dig(:chart_data, :labels)
    @chart_datasets    = @stats.dig(:chart_data, :datasets)
    @revenue_by_property = @stats[:revenue_by_property]
    @upcoming_arrivals = @stats[:upcoming_arrivals]

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
