class Public::ReservationsController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  layout "public"

  around_action :with_public_flag, only: [ :create ]
  before_action :set_reservation, only: [ :show, :confirm, :reject, :receipt, :add_payment, :delete_payment, :upload_voucher, :webpay_init, :webpay_return ]

  def search
    if params[:token].present?
      token = params[:token].strip
      @reservation = Reservation.find_by(token: token)

      if @reservation
        redirect_to public_reservation_path(@reservation.token)
        nil
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
    unless @reservation.pending?
      redirect_to public_reservation_path(@reservation.token), alert: "No se puede eliminar un comprobante de pago una vez que la reserva ha sido procesada o confirmada."
      return
    end

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

  def webpay_init
    if @reservation.cancelled?
      redirect_to public_reservation_path(@reservation.token), alert: "No se puede pagar una reserva cancelada."
      return
    end

    if @reservation.pending_balance <= 0
      redirect_to public_reservation_path(@reservation.token), alert: "Esta reserva ya se encuentra totalmente pagada."
      return
    end

    amount = @reservation.pending_balance.to_i
    buy_order = "RES-#{@reservation.id}-#{Time.now.to_i}"
    session_id = "SESSION-#{@reservation.token}"
    return_url = webpay_return_public_reservation_url(@reservation.token)

    begin
      tx = WebpayService.transaction_for(@reservation.property.company)
      response = tx.create(buy_order, session_id, amount, return_url)

      # Redirigir a Webpay
      redirect_to response["url"] + "?token_ws=" + response["token"], allow_other_host: true
    rescue => e
      Rails.logger.error "Error al iniciar Webpay: #{e.message}"
      redirect_to public_reservation_path(@reservation.token), alert: "Hubo un problema al contactar a Webpay. Por favor intenta más tarde."
    end
  end

  def webpay_return
    token_ws = params[:token_ws]

    if token_ws.blank?
      # Webpay cancelado por el usuario
      redirect_to public_reservation_path(@reservation.token), alert: "El pago fue cancelado."
      return
    end

    begin
      tx = WebpayService.transaction_for(@reservation.property.company)
      response = tx.commit(token_ws)

      if response["status"] == "AUTHORIZED" || response["status"] == "CAPTURED"
        # Crear el pago
        Payment.transaction do
          payment = @reservation.payments.create!(
            amount: response["amount"],
            payment_date: Time.current,
            payment_method: :card,
            transaction_type: :abono,
            operation_number: response["authorization_code"],
            status: :approved,
            notes: "Pago con Tarjeta (Terminada en #{response.dig("card_detail", "card_number")}) - Cód: #{response["authorization_code"]}"
          )

          # Transbank: VD (Débito) / VN, VC, SI, etc (Crédito) / VP (Prepago)
          payment_type = response["payment_type_code"].to_s

          # Estimación de comisión Transbank Webpay Plus (Tarifa estándar + IVA)
          # Débito/Prepago: 1.49% + IVA = 1.77%
          # Crédito: 2.95% + IVA = 3.51%
          commission_rate = [ "VD", "VP" ].include?(payment_type) ? 0.0177 : 0.0351
          commission_amount = (response["amount"].to_f * commission_rate).round

          if commission_amount > 0
            card_type_name = [ "VD", "VP" ].include?(payment_type) ? "Débito/Prepago" : "Crédito"

            Expense.create!(
              property: @reservation.property,
              amount: commission_amount,
              category: "other",
              expense_date: Time.current.to_date,
              description: "Comisión Webpay #{card_type_name} (Reserva ##{@reservation.id})"
            )
          end

          if @reservation.pending?
            Reservations::ConfirmService.call(@reservation)
          end
        end

        redirect_to public_reservation_path(@reservation.token), notice: "¡Pago exitoso! Tu reserva ha sido confirmada automáticamente."
      else
        redirect_to public_reservation_path(@reservation.token), alert: "El pago fue rechazado o no se pudo autorizar."
      end
    rescue => e
      Rails.logger.error "Error al confirmar Webpay: #{e.message}"
      redirect_to public_reservation_path(@reservation.token), alert: "Ocurrió un error al procesar la confirmación del pago."
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
    result = Reservations::ConfirmService.call(@reservation)
    @message = result[:message]
    @status = result[:status]
  end

  def reject
    result = Reservations::RejectService.call(@reservation)
    @message = result[:message]
    @status = result[:status]
  end

  private

  def set_payments
    @payments = @reservation.payments.with_attached_voucher.order(payment_date: :desc)
  end

  def set_reservation
    @reservation = Reservation.includes(property: :company).find_by!(token: params[:token])

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
    Current.created_by_public = true
    yield
  end
end
