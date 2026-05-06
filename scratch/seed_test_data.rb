
user = User.first
client1 = Client.find(1)

puts "Seeding data for User: #{user.email}"
puts "Seeding data for Client: #{client1.name} (ID: #{client1.id})"

# Create some extra clients
puts "Creating extra clients..."
10.times do
  Client.create(
    name: Faker::Name.name,
    rut: "#{rand(10000000..25000000)}-#{[ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'K' ].sample}",
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    email: Faker::Internet.email,
    user: user
  )
end

# Create reservations for Client 1
puts "Creating 30 reservations for Client 1..."
properties = Property.all.to_a
30.times do |i|
  prop = properties.sample
  # Distribute dates: some past, some future
  offset_days = i - 15
  start_time = (Time.current + offset_days.days).beginning_of_day + rand(8..18).hours

  if prop.per_day?
    end_time = start_time + rand(1..5).days
  else
    end_time = start_time + rand(1..6).hours
  end

  status = if start_time < Time.current
    [ :confirmed, :cancelled ].sample
  else
    [ :pending, :confirmed ].sample
  end

  # Calculate a dummy price
  duration = prop.per_day? ? (end_time.to_date - start_time.to_date).to_i : ((end_time - start_time) / 1.hour).ceil
  duration = 1 if duration < 1
  total_price = prop.base_price * duration

  res = Reservation.new(
    property: prop,
    client: client1,
    user: user,
    start_time: start_time,
    end_time: end_time,
    status: status,
    total_price: total_price
  )

  if res.save
    print "."
  else
    print "F"
  end
end

puts "\nSeed completed!"
