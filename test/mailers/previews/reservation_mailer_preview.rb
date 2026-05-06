# Preview all emails at http://localhost:3000/rails/mailers/reservation_mailer
class ReservationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/reservation_mailer/confirmed
  def confirmed
    ReservationMailer.confirmed
  end

  # Preview this email at http://localhost:3000/rails/mailers/reservation_mailer/cancelled
  def cancelled
    ReservationMailer.cancelled
  end
end
