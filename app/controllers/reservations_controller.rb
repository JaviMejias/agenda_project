class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: %i[ new create ]
  before_action :set_reservation, only: %i[ show edit update destroy ]

  def index
    respond_to do |format|
      format.html
      format.json {
        @reservations = Reservation.for_calendar(
          property_id: params[:property_id],
          start_date_str: params[:start],
          end_date_str: params[:end],
          exclude_id: params[:exclude_id]
        )
      }
    end
  end

  def list
    authorize Reservation
    @reservations = Reservation.all.for_list(query: params[:q], status: params[:status])
    @filename = "reservas_#{Time.current.strftime('%Y%m%d_%H%M')}"

    respond_to do |format|
      format.html do
        @pagy, @reservations = pagy(@reservations, limit: 10)
      end
      format.xlsx do
        response.headers["Content-Disposition"] = "attachment; filename=\"#{@filename}.xlsx\""
      end
      format.pdf do
        render pdf: @filename,
               template: "reservations/list_export",
               layout: "pdf",
               formats: [ :html ],
               disposition: "attachment"
      end
    end
  end

  def calendar_list
    authorize Reservation
    start_date = Time.zone.parse(params[:start]) rescue nil
    end_date = Time.zone.parse(params[:end]) rescue nil

    @reservations = Reservation.includes(:property).order(start_time: :asc)
    if start_date && end_date
      @reservations = @reservations.where("start_time < ? AND end_time > ?", end_date, start_date)
    end

    @pagy, @reservations = pagy(@reservations, limit: 5)

    render partial: "reservations/calendar_list", locals: {
      reservations: @reservations,
      pagy: @pagy,
      view_type: params[:view_type]
    }
  end

  def show
    authorize @reservation
  end

  def new
    authorize Reservation
    @reservation = @property.reservations.build
  end

  def edit
    authorize @reservation
    if @reservation.cancelled?
      redirect_to reservation_path(@reservation), alert: "Esta reserva está cancelada y es inamovible."
    end
  end

  def create
    authorize Reservation
    @reservation = @property.reservations.build(reservation_params)
    @reservation.user = current_user
    @reservation.status ||= :pending

    respond_to do |format|
      if @reservation.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("calendar-view", partial: "shared/calendar_container", locals: { property: @property, mode: "booking", omit_controller: true, omit_inputs: true }),
            turbo_stream.replace("reservation_form_container", partial: "reservations/booking_form", locals: { property: @property, reservation: @property.reservations.build }),
            turbo_stream.prepend("flash-container", partial: "shared/flash_message", locals: { type: "notice", message: "Reserva creada exitosamente." })
          ]
        end
        format.html { redirect_to property_path(@property), notice: "Reserva creada exitosamente." }
        format.json { render :show, status: :created, location: @reservation }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("flash-container", partial: "shared/flash_message", locals: { type: "alert", message: "No se pudo crear la reserva. Revisa los errores del formulario." }),
            turbo_stream.replace("reservation_form_container", partial: "reservations/booking_form", locals: { property: @property, reservation: @reservation })
          ]
        end
        format.html { render template: "properties/show", status: :unprocessable_entity }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @reservation
    respond_to do |format|
      if @reservation.update(reservation_params)
        path = params[:from] == "list" ? list_reservations_path : reservations_path
        format.html { redirect_to path, notice: "Reserva actualizada.", status: :see_other }
        format.json { render :show, status: :ok, location: @reservation }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("flash-container", partial: "shared/flash_message", locals: { type: "alert", message: "No se pudo actualizar la reserva. Revisa los errores del formulario." })
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @reservation
    if @reservation.destroyable?
      @reservation.destroy
      respond_to do |format|
        format.html { redirect_to reservations_path, notice: "Bloqueo eliminado correctamente.", status: :see_other }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to reservations_path, alert: "No se permite eliminar reservas reales, solo cancelarlas cambiando su estado.", status: :see_other }
        format.json { render json: { error: "No se permite eliminar reservas" }, status: :forbidden }
      end
    end
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:client_name, :client_id, :start_time, :end_time, :status)
  end
end
