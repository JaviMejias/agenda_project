# frozen_string_literal: true

module DateRangeParams
  extend ActiveSupport::Concern

  included do
    helper_method :date_range_params_included?
  end

  private

  def parse_date_range
    @start_date = parse_date(params[:start_date]) || Time.zone.today.beginning_of_month
    @end_date   = parse_date(params[:end_date])   || Time.zone.today.end_of_month
    @range      = @start_date.beginning_of_day..@end_date.end_of_day
    @company_id = params[:company_id]
  end

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end

  def date_range_params_included?
    true
  end
end
