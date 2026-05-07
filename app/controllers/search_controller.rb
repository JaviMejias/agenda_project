class SearchController < ApplicationController
  before_action :authenticate_user!

  def global
    query = params[:q].to_s.strip
    return render json: { results: [] } if query.length < 2

    results = []

    # Buscar Clientes
    clients = Client.search(query).limit(5)
    clients.each do |c|
      results << {
        category: "Clientes",
        title: c.name,
        subtitle: c.rut,
        url: client_path(c),
        icon: "fa-user"
      }
    end

    # Buscar Propiedades
    properties = Property.search(query).limit(5)
    properties.each do |p|
      results << {
        category: "Propiedades",
        title: p.name,
        subtitle: p.address,
        url: property_path(p),
        icon: "fa-house-chimney"
      }
    end

    # Buscar Reservas (por nombre de cliente)
    reservations = Reservation.joins(:property).where("client_name ILIKE ?", "%#{query}%").limit(5)
    reservations.each do |r|
      results << {
        category: "Reservas",
        title: "Reserva ##{r.id} - #{r.client_name}",
        subtitle: "#{r.property.name} (#{r.start_time.strftime('%d/%m')})",
        url: reservation_path(r),
        icon: "fa-calendar-check"
      }
    end

    # Buscar Usuarios (SOLO PARA ADMINS)
    if current_user.admin?
      users = User.where("email ILIKE ?", "%#{query}%").limit(5)
      users.each do |u|
        results << {
          category: "Usuarios",
          title: u.email,
          subtitle: "Rol: #{u.role}",
          url: user_path(u),
          icon: "fa-users-gear"
        }
      end
    end

    render json: { results: results }
  end
end
