class ReportStatsService
  def initialize(user, start_date, end_date, company_id: nil)
    @user = user
    @start_date = start_date
    @end_date = end_date
    @company_id = company_id
    @range = @start_date.beginning_of_day..@end_date.end_of_day

    @reservations_in_range = user.reservations_through_properties.in_range(@range)
    @properties = user.properties

    if @company_id.present?
      @reservations_in_range = @reservations_in_range.joins(:property).where(properties: { company_id: @company_id })
      @properties = @properties.where(company_id: @company_id)
    end
  end

  def stats
    total_income = @reservations_in_range.confirmed.sum(:total_price)
    total_expenses = Expense.where(property: @properties, expense_date: @range).sum(:amount)

    # Caja Real: Pagos realizados en el periodo
    abonos = Payment.joins(reservation: :property)
                   .where(properties: { id: @properties.ids }, payment_date: @range, transaction_type: :abono)
                   .sum(:amount)
    reembolsos = Payment.joins(reservation: :property)
                       .where(properties: { id: @properties.ids }, payment_date: @range, transaction_type: :reembolso)
                       .sum(:amount)
    actual_cash_in = abonos - reembolsos

    {
      total_income: total_income,
      total_loss: @reservations_in_range.blocked.sum(:total_price),
      total_expenses: total_expenses,
      actual_cash_in: actual_cash_in,
      net_profit: actual_cash_in - total_expenses,
      reservations_count: @reservations_in_range.active.count,
      properties_data: properties_data,
      monthly_trend: monthly_trend
    }
  end

  private

  def properties_data
    aggregated = @properties
      .left_joins(:reservations)
      .merge(Reservation.in_range(@range))
      .group("properties.id", "properties.name", "properties.color")
      .select(
        "properties.id",
        "properties.name",
        "properties.color",
        "SUM(CASE WHEN reservations.status = 1 THEN reservations.total_price ELSE 0 END) AS income",
        "SUM(CASE WHEN reservations.status = 3 THEN reservations.total_price ELSE 0 END) AS loss"
      )

    active_reservations = @reservations_in_range.active
    reservations_by_property = active_reservations.group_by(&:property_id)

    aggregated.map do |p|
      res = reservations_by_property[p.id] || []
      {
        name: p.name,
        income: p.income.to_f,
        loss: p.loss.to_f,
        occupancy_rate: calculate_occupancy_rate_from(res),
        reservations_count: res.count,
        color: p.color
      }
    end
  end

  def monthly_trend
    six_months_ago = 5.months.ago.beginning_of_month.beginning_of_day

    scope = @user.reservations_through_properties.confirmed.where("start_time >= ?", six_months_ago)
    scope = scope.joins(:property).where(properties: { company_id: @company_id }) if @company_id.present?

    reservations = scope.select(:id, :start_time, :total_price)

    data = reservations.group_by { |r| r.start_time.beginning_of_month }.transform_values do |res|
      res.sum(&:total_price)
    end

    (0..5).to_a.reverse.map do |i|
      month_start = i.months.ago.beginning_of_month
      {
        month: I18n.l(month_start, format: "%B"),
        income: data[month_start] || 0
      }
    end
  end

  def monthly_income_scope(range)
    scope = @user.reservations_through_properties.confirmed.in_range(range)
    @company_id.present? ? scope.joins(:property).where(properties: { company_id: @company_id }) : scope
  end

  def calculate_occupancy_rate_from(reservations)
    total_days_in_range = (@end_date - @start_date).to_i + 1
    return 0 if total_days_in_range <= 0

    occupied_days = reservations.sum do |r|
      r_start = [ r.start_time.to_date, @start_date ].max
      r_end   = [ r.end_time.to_date, @end_date ].min
      [ (r_end - r_start).to_i, 0 ].max
    end

    (occupied_days.to_f / total_days_in_range * 100).round(1)
  end
end
