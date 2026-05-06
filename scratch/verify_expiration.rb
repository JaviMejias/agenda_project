p = Property.first
u = User.first
c = Client.first

# Create an "old" reservation (30 hours ago)
r = Reservation.new(
  property: p,
  user: u,
  client: c,
  start_time: 1.week.from_now,
  end_time: 1.week.from_now + 2.hours,
  status: :pending,
  created_at: 30.hours.ago
)

# Use r.save!(validate: false) if needed, but here we just want to test the controller logic
# Actually, I'll just create it normally and then update_column to change created_at
r.save!
r.update_column(:created_at, 30.hours.ago)

puts "Reserva antigua creada con ID: #{r.id}"
puts "Token: #{r.token}"
puts "Creada el: #{r.created_at}"
