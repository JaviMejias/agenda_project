class DashboardController < ApplicationController
  def index
    authorize :dashboard, :index?
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Time.zone.now.beginning_of_month.to_date
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Time.zone.now.end_of_month.to_date
    @range = @start_date.beginning_of_day..@end_date.end_of_day
    @company_id = params[:company_id]
    
    stats_service = DashboardStatsService.new(current_user, @range, company_id: @company_id)
    @stats = stats_service.stats

    @completed_revenue = @stats[:completed_revenue]
    @projected_revenue = @stats[:projected_revenue]
    @pending_count = @stats[:pending_count]
    @total_count = @stats[:total_count]
    @status_counts = @stats[:status_counts]
    @chart_labels = @stats[:chart_data][:labels]
    @chart_datasets = @stats[:chart_data][:datasets]
    @revenue_by_property = @stats[:revenue_by_property]
    @upcoming_arrivals = @stats[:upcoming_arrivals]
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
