token = "7vK5DuqR5cF4RDXQ6S7aGUNs"
r = Reservation.find_by(token: token)
if r
  puts "Reserva encontrada: #{r.id}"
  puts "Estado inicial: #{r.status}"
  r.update!(status: :confirmed)
  puts "Estado final: #{r.status}"
else
  puts "Reserva no encontrada con token #{token}"
end
