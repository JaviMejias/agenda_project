class ReservationMailer < ApplicationMailer
  def pending_confirmation(reservation)
    @reservation = reservation
    @client = @reservation.client
    @property = @reservation.property
    @user = @reservation.user

    mail(
      to: @client.email,
      subject: "Solicitud de reserva - #{@property.name}"
    )
  end

  def confirmed(reservation)
    @reservation = reservation
    @client = @reservation.client
    @property = @reservation.property

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
