p = Property.first
u = User.first
c = Client.first || Client.create!(name: "Test Client", email: "test@example.com", user: u)

# Create a pending reservation
r = Reservation.new(
  property: p,
  user: u,
  client: c,
  start_time: 1.week.from_now,
  end_time: 1.week.from_now + 2.hours,
  status: :pending
)

if r.save
  puts "Reserva pendiente creada con ID: #{r.id}"
  puts "Token: #{r.token}"
  puts "Correo enviado. Revisa letter_opener."
else
  puts "Error al crear reserva: #{r.errors.full_messages}"
end
