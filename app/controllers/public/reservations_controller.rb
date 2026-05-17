class Public::ReservationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "public"

  before_action :set_reservation, only: [ :show, :confirm, :reject, :receipt, :add_payment, :delete_payment ]

  def show
    @payments = @reservation.payments.with_attached_voucher.order(payment_date: :desc)
    @new_payment = @reservation.payments.build
  end

  def delete_payment
    @payment = @reservation.payments.find(params[:payment_id])
    if @payment.destroy
      redirect_to public_reservation_path(@reservation.token), notice: "El comprobante de pago fue eliminado exitosamente."
    else
      redirect_to public_reservation_path(@reservation.token), alert: "No se pudo eliminar el comprobante."
    end
  end

  def receipt
    respond_to do |format|
      format.pdf do
        render pdf: "Comprobante_#{@reservation.id}",
               template: "reservations/receipt",
               layout: "pdf",
               formats: [ :html ],
               disposition: "inline"
      end
    end
  end

  def create
    @property = Property.find(params[:public_property_id] || params[:property_id])

    # 1. Buscar o crear el cliente asociado al dueño de la propiedad
    @client = @property.user.clients.find_or_initialize_by(email: params[:client_email])
    @client.name = params[:client_name]
    @client.phone = params[:client_phone]
    @client.rut = params[:client_rut]

    unless @client.save
      @reservation = @property.reservations.build(reservation_params)
      @reservation.errors.add(:base, "No se pudo guardar los datos de contacto. Revisa la información.")
      render "public/properties/booking", status: :unprocessable_entity
      return
    end

    # 2. Construir la reserva
    @reservation = @property.reservations.build(reservation_params)
    @reservation.user = @property.user
    @reservation.client = @client
    @reservation.status = :pending

    Property.transaction do
      @property.lock!
      if @reservation.save
        redirect_to public_reservation_path(@reservation.token), notice: "¡Reserva solicitada con éxito! Revisa tu correo electrónico para el seguimiento."
      else
        render "public/properties/booking", status: :unprocessable_entity
      end
    end
  end

  def add_payment
    @payment = @reservation.payments.build(payment_params)
    @payment.payment_method = :transfer
    @payment.transaction_type = :abono
    @payment.payment_date = Time.current

    if @payment.save
      Notification.create!(
        user: @reservation.user,
        notifiable: @payment,
        message: "¡Nuevo Comprobante! #{@reservation.client_name} ha subido un comprobante de pago para la reserva ##{@reservation.id}."
      )
      redirect_to public_reservation_path(@reservation.token), notice: "El comprobante de pago fue subido exitosamente y está siendo verificado."
    else
      @payments = @reservation.payments.with_attached_voucher.order(payment_date: :desc)
      @new_payment = @payment
      render :show, status: :unprocessable_entity
    end
  end

  def confirm
    result = @reservation.confirm_by_client!
    @message = result[:message]
    @status = result[:status]
  end

  def reject
    result = @reservation.reject_by_client!
    @message = result[:message]
    @status = result[:status]
  end

  private

  def set_reservation
    @reservation = Reservation.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    render plain: "Reserva no encontrada", status: :not_found
  end

  def reservation_params
    params.require(:reservation).permit(:start_time, :end_time)
  end

  def payment_params
    p = params.require(:payment).permit(:amount, :notes, :operation_number, :voucher)
    if p[:amount].present? && p[:amount].is_a?(String)
      p[:amount] = p[:amount].gsub(".", "").gsub(",", ".")
    end
    p
  end
end
