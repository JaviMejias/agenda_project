class ReportsController < ApplicationController
  include DateRangeParams
  before_action :authenticate_user!
  before_action :parse_date_range

  def index
    authorize :report, :index?

    @stats              = ReportStatsService.new(@start_date, @end_date, company_id: @company_id).stats
    @total_income       = @stats[:total_income]
    @total_loss         = @stats[:total_loss]
    @total_expenses     = @stats[:total_expenses]
    @actual_cash_in    = @stats[:actual_cash_in]
    @net_profit         = @stats[:net_profit]
    @reservations_count = @stats[:reservations_count]
    @properties_data    = @stats[:properties_data]
    @monthly_trend      = @stats[:monthly_trend]

    respond_to do |format|
      format.html
      format.xlsx {
        response.headers["Content-Disposition"] = "attachment; filename=\"Reporte_#{Time.zone.today}.xlsx\""
      }
      format.pdf do
        render pdf: "Reporte_#{Time.zone.today}",
               template: "reports/index",
               formats: [ :pdf ],
               layout: "pdf",
               orientation: "Landscape",
               lowquality: false,
               encoding: "UTF-8",
               zoom: 1,
               dpi: 300
      end
    end
  end
end
