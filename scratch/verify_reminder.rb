p = Property.first
u = User.first
r = Reservation.new(
  property: p,
  user: u,
  client_name: "Test Reminder",
  start_time: 48.hours.from_now,
  end_time: 50.hours.from_now,
  status: :confirmed
)

if r.save
  puts "Reserva guardada ID: #{r.id}"
  scheduled_jobs = SolidQueue::Job.where(class_name: "ReservationReminderJob")
  puts "Trabajos programados encontrados: #{scheduled_jobs.count}"
  scheduled_jobs.each do |job|
    puts "Trabajo ID: #{job.id}, Programado para: #{job.scheduled_at}"
  end
else
  puts "Error al guardar reserva: #{r.errors.full_messages.join(', ')}"
end
