admin = User.find_or_initialize_by(email: "admin@agenda.cl")
admin.update!(
  first_name: "Admin",
  last_name: "Soporte",
  password: "password123",
  role: :admin
)

normal = User.find_or_initialize_by(email: "usuario@agenda.cl")
normal.update!(
  first_name: "Normal",
  last_name: "Soporte",
  password: "password123",
  role: :normal
)
