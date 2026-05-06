class ReportsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    authorize :report, :index?
    
    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
    @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.end_of_month
    
    @company_id = params[:company_id]
    @report_stats = ReportStatsService.new(@start_date, @end_date, company_id: @company_id).stats
    
    @total_income = @report_stats[:total_income]
    @total_loss = @report_stats[:total_loss]
    @reservations_count = @report_stats[:reservations_count]
    @properties_data = @report_stats[:properties_data]
    @monthly_trend = @report_stats[:monthly_trend]

    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=\"Reporte_#{Date.today}.xlsx\""
      }
      format.pdf do
        render pdf: "Reporte_#{Date.today}",
               template: "reports/index",
               formats: [:pdf],
               layout: 'pdf',
               orientation: 'Landscape',
               lowquality: false,
               encoding: 'UTF-8',
               zoom: 1,
               dpi: 300
      end
    end
  end
end
