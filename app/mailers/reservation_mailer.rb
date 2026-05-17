class ReservationMailer < ApplicationMailer
  def pending_confirmation(reservation, created_by_public: false)
    @reservation = reservation
    @client = @reservation.client
    @property = @reservation.property
    @user = @reservation.user
    @created_by_public = created_by_public

    mail(
      to: @client.email,
      subject: "Solicitud de reserva - #{@property.name}"
    )
  end

  def confirmed(reservation)
    @reservation = reservation
    @client = @reservation.client
    @property = @reservation.property

    begin
      pdf_html = ApplicationController.render(
        template: "reservations/receipt",
        layout: "layouts/pdf",
        assigns: { reservation: @reservation }
      )
      pdf = WickedPdf.new.pdf_from_string(pdf_html)
      attachments["Comprobante_Reserva_#{@reservation.id}.pdf"] = pdf
    rescue => e
      Rails.logger.error "No se pudo generar o adjuntar el comprobante PDF: #{e.message}"
    end

    mail(
      to: @client.email,
      subject: "Confirmación de reserva - #{@property.name}"
    )
  end

  def cancelled(reservation)
    @reservation = reservation
    @client = @reservation.client
    @property = @reservation.property

    mail(
      to: @client.email,
      subject: "Cancelación de reserva - #{@property.name}"
    )
  end

  def reminder(reservation)
    @reservation = reservation
    @client = @reservation.client
    @property = @reservation.property

    mail(
      to: @client.email,
      subject: "Recordatorio de reserva - #{@property.name}"
    )
  end
end
