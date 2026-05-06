class ReportStatsService
  def initialize(start_date, end_date, company_id: nil)
    @start_date = start_date
    @end_date = end_date
    @company_id = company_id
    @range = @start_date.beginning_of_day..@end_date.end_of_day
    
    @reservations_in_range = Reservation.in_range(@range)
    @properties = Property.all
    
    if @company_id.present?
      @reservations_in_range = @reservations_in_range.joins(:property).where(properties: { company_id: @company_id })
      @properties = @properties.where(company_id: @company_id)
    end
  end

  def stats
    {
      total_income: @reservations_in_range.confirmed.sum(:total_price),
      total_loss: @reservations_in_range.blocked.sum(:total_price),
      reservations_count: @reservations_in_range.active.count,
      properties_data: properties_data,
      monthly_trend: monthly_trend
    }
  end

  private

  def properties_data
    @properties.map do |property|
      res = property.reservations.in_range(@range)
      
      income = res.confirmed.sum(:total_price)
      loss = res.blocked.sum(:total_price)
      
      {
        name: property.name,
        income: income,
        loss: loss,
        occupancy_rate: calculate_occupancy_rate(property, res),
        color: property.color
      }
    end
  end

  def calculate_occupancy_rate(property, reservations)
    total_days_in_range = (@end_date - @start_date).to_i + 1
    return 0 if total_days_in_range <= 0

    occupied_days = 0
    reservations.active.each do |r|
      r_start = [r.start_time.to_date, @start_date].max
      r_end = [r.end_time.to_date, @end_date].min
      days = (r_end - r_start).to_i
      occupied_days += [days, 0].max
    end
    
    (occupied_days.to_f / total_days_in_range * 100).round(1)
  end

  def monthly_trend
    (0..5).to_a.reverse.map do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
      range = month_start.beginning_of_day..month_end.end_of_day
      {
        month: I18n.l(month_start, format: '%B'),
        income: Reservation.confirmed.in_range(range).yield_self { |scope| @company_id.present? ? scope.joins(:property).where(properties: { company_id: @company_id }) : scope }.sum(:total_price)
      }
    end
  end
end
