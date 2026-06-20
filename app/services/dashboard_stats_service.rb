class DashboardStatsService
  def initialize(user, range, company_id: nil)
    @user = user
    @range = range
    @company_id = company_id

    @reservations = user.reservations_through_properties.in_range(range)
    @properties = user.properties

    if @company_id.present?
      @reservations = @reservations.joins(:property).where(properties: { company_id: @company_id })
      @properties = @properties.where(company_id: @company_id)
    end
  end

  def stats
    {
      completed_revenue: @reservations.confirmed.sum(:total_price),
      projected_revenue: @reservations.projected.sum(:total_price),
      actual_cash_in: Payment.joins(reservation: :property).where(properties: { id: @properties.ids }, payment_date: @range, transaction_type: :abono).sum(:amount) -
                      Payment.joins(reservation: :property).where(properties: { id: @properties.ids }, payment_date: @range, transaction_type: :reembolso).sum(:amount),
      total_expenses: Expense.where(property: @properties, expense_date: @range).sum(:amount),
      pending_count: @reservations.pending.count,
      total_count: @reservations.active.count,
      status_counts: @reservations.group(:status).count,
      chart_data: chart_data,
      revenue_by_property: revenue_by_property,
      upcoming_arrivals: @reservations.upcoming.limit(5).includes(:property)
    }
  end

  private

  def chart_data
    active_dates = @reservations.confirmed
                                .pluck("DATE(start_time)")
                                .uniq
                                .sort

    labels = active_dates.map { |d| d.to_date.strftime("%d %b") }

    revenue_by_property_date = @reservations.confirmed
                                            .group(:property_id, "DATE(start_time)")
                                            .sum(:total_price)

    datasets = @properties.map do |property|
      data_points = active_dates.map { |date| revenue_by_property_date[[ property.id, date ]] || 0 }

      {
        label: property.name,
        color: property.color || "#6366f1",
        data: data_points
      }
    end

    datasets.reject! { |ds| ds[:data].all?(&:zero?) }

    { labels: labels, datasets: datasets }
  end

  def revenue_by_property
    @properties
         .joins(:reservations)
         .merge(Reservation.confirmed.in_range(@range))
         .group(:name)
         .sum("reservations.total_price")
  end
end
