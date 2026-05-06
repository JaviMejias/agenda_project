json.array! @reservations.where.not(status: :cancelled) do |reservation|
  json.id reservation.id
  if reservation.blocked?
    json.title "🚫 NO DISPONIBLE: #{reservation.property.name}"
    json.color "#334155" # slate-700
  else
    json.title "#{reservation.property.name} - #{reservation.client_name}"
    json.color reservation.property.color || "#4f46e5"
  end

  if reservation.property.per_day?
    json.start reservation.start_time.strftime("%Y-%m-%d")
    json.end reservation.end_time.strftime("%Y-%m-%d")
    json.allDay true
  else
    json.start reservation.start_time.strftime("%Y-%m-%dT%H:%M:%S")
    json.end reservation.end_time.strftime("%Y-%m-%dT%H:%M:%S")
  end
  json.url reservation_path(reservation, from: "calendar")

  if reservation.status == "pending"
    json.borderColor "#eab308"
  elsif reservation.blocked?
    json.borderColor "#0f172a"
  end
end
