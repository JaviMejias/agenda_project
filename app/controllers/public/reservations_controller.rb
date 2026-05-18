class Public::ReservationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "public"

  around_action :with_public_flag, only: [ :create ]
  before_action :set_reservation, only: [ :show, :confirm, :reject, :receipt, :add_payment, :delete_payment, :upload_voucher ]

  def search
    if params[:token].present?
      token = params[:token].strip
      @reservation = Reservation.find_by(token: token)

      if @reservation
        redirect_to public_reservation_path(@reservation.token)
        return
      else
        flash.now[:alert] = "El código ingresado no corresponde a ninguna reserva activa. Por favor, verifica el código e inténtalo de nuevo."
      end
    end
  end

  def show
    set_payments
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

  def upload_voucher
    @payment = @reservation.payments.find(params[:payment_id])
    if params[:payment] && params[:payment][:voucher].present?
      @payment.voucher.attach(params[:payment][:voucher])

      @payment.notify_admin_of_updated_voucher!
      redirect_to public_reservation_path(@reservation.token), notice: "El comprobante fue subido exitosamente."
    else
      redirect_to public_reservation_path(@reservation.token), alert: "Debes seleccionar un archivo para el comprobante."
    end
  end

  def receipt
    if @reservation.cancelled?
      redirect_to public_reservation_path(@reservation.token), alert: "No se puede descargar el comprobante de una reserva cancelada."
      return
    end

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

    if @property.user.nil?
      fallback_admin = User.admin.first || User.normal.first
      if fallback_admin
        @property.update!(user: fallback_admin)
        Rails.logger.warn "Se asignó automáticamente el usuario ID #{fallback_admin.id} como administrador de la propiedad ID #{@property.id} para evitar huérfanos."
      else
        @reservation = @property.reservations.build(reservation_params)
        @reservation.errors.add(:base, "Esta propiedad no tiene un administrador válido asignado.")
        render "public/properties/booking", status: :unprocessable_entity
        return
      end
    end

    @client = @property.user.clients.find_by(rut: params[:client_rut]) ||
              @property.user.clients.find_or_initialize_by(email: params[:client_email])

    @client.name = params[:client_name]
    @client.phone = params[:client_phone]
    @client.email = params[:client_email]
    @client.rut = params[:client_rut]

    unless @client.save
      @reservation = @property.reservations.build(reservation_params)
      @reservation.errors.add(:base, "No se pudo guardar los datos de contacto. Revisa la información:")
      @client.errors.full_messages.each do |msg|
        @reservation.errors.add(:base, msg)
      end
      render "public/properties/booking", status: :unprocessable_entity
      return
    end

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
    if @reservation.cancelled?
      redirect_to public_reservation_path(@reservation.token), alert: "No se pueden registrar pagos en una reserva cancelada."
      return
    end

    if @reservation.pending_balance <= 0
      redirect_to public_reservation_path(@reservation.token), alert: "Esta reserva ya se encuentra totalmente pagada."
      return
    end

    @payment = @reservation.payments.build(payment_params)
    @payment.payment_method = :transfer
    @payment.transaction_type = :abono
    @payment.payment_date = Time.current

    if @payment.save
      @payment.notify_admin_of_new_payment!
      redirect_to public_reservation_path(@reservation.token), notice: "El comprobante de pago fue subido exitosamente y está siendo verificado."
    else
      set_payments
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

  def set_payments
    @payments = @reservation.payments.with_attached_voucher.order(payment_date: :desc)
  end

  def set_reservation
    @reservation = Reservation.includes(property: { company: :bank_accounts }).find_by!(token: params[:token])

    if Time.zone.now > @reservation.end_time.end_of_day
      render "public/reservations/expired", status: :gone
      nil
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to search_public_reservations_path, alert: "El código de reserva no es válido, ha expirado o la reserva no existe." }
      format.any { render plain: "Reserva no encontrada", status: :not_found }
    end
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

  def with_public_flag
    Thread.current[:created_by_public] = true
    yield
  ensure
    Thread.current[:created_by_public] = nil
  end
end
