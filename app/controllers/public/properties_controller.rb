class Public::PropertiesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "public"

  before_action :set_property, only: [:show, :booking]

  def index
    @properties = property_scope.search_public(params[:query])
                                .by_pricing_model(params[:pricing_model])
  end

  def show
  end

  def booking
    if params[:guest] == "true"
      session[:continue_as_guest] = true
      redirect_to booking_public_property_path(@property)
      return
    end

    if user_signed_in? || session[:continue_as_guest] == true
      @reservation = @property.reservations.build
      render :booking
    else
      session[:user_return_to] = booking_public_property_path(@property)
      render :booking_gateway
    end
  end

  def events
    @property = Property.find(params[:id])
    @reservations = Reservation.for_calendar(
      property_id: @property.id,
      start_date_str: params[:start],
      end_date_str: params[:end],
      exclude_id: params[:exclude_id]
    )

    render json: @reservations.where.not(status: :cancelled).map { |reservation|
      hash = {
        id: reservation.id,
        color: @property.color || "#4f46e5"
      }

      if reservation.blocked?
        hash[:title] = "🚫 NO DISPONIBLE"
        hash[:color] = "#334155" # slate-700
        hash[:borderColor] = "#0f172a"
      else
        hash[:title] = "📅 Reservado"
        if reservation.status == "pending"
          hash[:borderColor] = "#eab308"
        end
      end

      if @property.per_day?
        hash[:start] = reservation.start_time.strftime("%Y-%m-%d")
        hash[:end] = reservation.end_time.strftime("%Y-%m-%d")
        hash[:allDay] = true
      else
        hash[:start] = reservation.start_time.strftime("%Y-%m-%dT%H:%M:%S")
        hash[:end] = reservation.end_time.strftime("%Y-%m-%dT%H:%M:%S")
      end

      hash
    }
  end

  private

  def property_scope
    Property.with_attached_images
  end

  def set_property
    @property = property_scope.find(params[:id])
  end
end
