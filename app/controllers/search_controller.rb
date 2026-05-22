class SearchController < ApplicationController
  before_action :authenticate_user!

  def global
    query = params[:q].to_s.strip
    return render json: { results: [] } if query.length < 2

    results = []

    clients = policy_scope(Client).search(query).limit(5)
    clients.each do |c|
      results << {
        category: "Clientes",
        title: c.name,
        subtitle: c.rut,
        url: client_path(c),
        icon: "fa-user"
      }
    end

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

    # Search by token (código de reserva) first — shown in a dedicated category
    token_matches = policy_scope(Reservation).where("token ILIKE ?", "#{query}%").includes(:property).limit(3)
    token_ids = token_matches.map(&:id)
    token_matches.each do |r|
      results << {
        category: "Código de Reserva",
        title: "Reserva ##{r.id} — #{r.client_name}",
        subtitle: "#{r.token} · #{r.property.name}",
        url: reservation_path(r),
        icon: "fa-key"
      }
    end

    reservations = policy_scope(Reservation).search(query).where.not(id: token_ids).includes(:property).limit(5)
    reservations.each do |r|
      results << {
        category: "Reservas",
        title: "Reserva ##{r.id} - #{r.client_name}",
        subtitle: "#{r.property.name} (#{r.start_time.strftime('%d/%m')})",
        url: reservation_path(r),
        icon: "fa-calendar-check"
      }
    end

    if current_user.admin?
      users = User.search(query).limit(5)
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
