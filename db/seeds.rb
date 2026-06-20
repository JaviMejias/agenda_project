admin = User.find_or_initialize_by(email: "admin@agenda.cl")
admin.update!(
  first_name: "Admin",
  last_name: "Soporte",
  password: "password123",
  rut: "12345678-5",
  phone: "+56911111111",
  role: :admin
)

normal = User.find_or_initialize_by(email: "usuario@agenda.cl")
normal.update!(
  first_name: "Normal",
  last_name: "Soporte",
  password: "password123",
  rut: "11111111-1",
  phone: "+56922222222",
  role: :normal
)
