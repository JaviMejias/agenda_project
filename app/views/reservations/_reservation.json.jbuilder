json.extract! reservation, :id, :property_id, :client_name, :start_date, :end_date, :status, :total_price, :created_at, :updated_at
json.url reservation_url(reservation, format: :json)
