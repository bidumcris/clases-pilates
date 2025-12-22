# Limpiar datos existentes (solo en desarrollo)
if Rails.env.development?
  puts "Limpiando datos existentes..."
  Reservation.destroy_all
  Request.destroy_all
  Credit.destroy_all
  Payment.destroy_all
  PilatesClass.destroy_all
  Instructor.destroy_all
  Room.destroy_all
  User.where.not(level: :admin).destroy_all
end

# Crear Salas
puts "Creando salas..."
room1 = Room.find_or_create_by!(name: "Planta Alta - Privadas") do |r|
  r.room_type = :planta_alta_privadas
  r.capacity = 8
end

room2 = Room.find_or_create_by!(name: "Circuito") do |r|
  r.room_type = :circuito
  r.capacity = 12
end

room3 = Room.find_or_create_by!(name: "Planta Baja - Mat y Accesorios") do |r|
  r.room_type = :planta_baja_mat_accesorios
  r.capacity = 15
end

# Crear Instructores
puts "Creando instructores..."
instructor1 = Instructor.find_or_create_by!(email: "maria.garcia@pilates.com") do |i|
  i.name = "María García"
  i.phone = "+34 600 123 456"
end

instructor2 = Instructor.find_or_create_by!(email: "juan.lopez@pilates.com") do |i|
  i.name = "Juan López"
  i.phone = "+34 600 234 567"
end

instructor3 = Instructor.find_or_create_by!(email: "ana.martinez@pilates.com") do |i|
  i.name = "Ana Martínez"
  i.phone = "+34 600 345 678"
end

# Crear Usuarios de prueba
puts "Creando usuarios..."
user_basic = User.find_or_create_by!(email: "basico@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.level = :basic
end

user_intermediate = User.find_or_create_by!(email: "intermedio@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.level = :intermediate
end

user_advanced = User.find_or_create_by!(email: "avanzado@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.level = :advanced
end

# Crear Admin
admin = User.find_or_create_by!(email: "admin@pilates.com") do |u|
  u.password = "admin123"
  u.password_confirmation = "admin123"
  u.level = :admin
end

# Crear Créditos para usuarios
puts "Creando créditos..."
[user_basic, user_intermediate, user_advanced].each do |user|
  # Créditos para diciembre
  Credit.find_or_create_by!(user: user, expires_at: Date.new(Date.current.year, 12, 31)) do |c|
    c.amount = 10
    c.used = false
  end
  
  # Créditos para enero
  Credit.find_or_create_by!(user: user, expires_at: Date.new(Date.current.year + 1, 1, 31)) do |c|
    c.amount = 8
    c.used = false
  end
end

# Crear Clases de Pilates
puts "Creando clases de pilates..."
start_date = Date.tomorrow
instructors = [instructor1, instructor2, instructor3]
rooms = [room1, room2, room3]
levels = [:basic, :intermediate, :advanced]

# Crear clases para los próximos 7 días
7.times do |day|
  current_date = start_date + day.days
  
  # Clases por la mañana (9:00, 10:00, 11:00)
  [9, 10, 11].each do |hour|
    PilatesClass.find_or_create_by!(
      name: "Clase #{levels.sample.to_s.capitalize} - #{current_date.strftime('%d/%m')} #{hour}:00",
      start_time: Time.zone.parse("#{current_date} #{hour}:00"),
      room: rooms.sample,
      instructor: instructors.sample
    ) do |pc|
      pc.level = levels.sample
      pc.end_time = Time.zone.parse("#{current_date} #{hour}:00") + 1.hour
      pc.max_capacity = [8, 10, 12, 15].sample
    end
  end
  
  # Clases por la tarde (17:00, 18:00, 19:00)
  [17, 18, 19].each do |hour|
    PilatesClass.find_or_create_by!(
      name: "Clase #{levels.sample.to_s.capitalize} - #{current_date.strftime('%d/%m')} #{hour}:00",
      start_time: Time.zone.parse("#{current_date} #{hour}:00"),
      room: rooms.sample,
      instructor: instructors.sample
    ) do |pc|
      pc.level = levels.sample
      pc.end_time = Time.zone.parse("#{current_date} #{hour}:00") + 1.hour
      pc.max_capacity = [8, 10, 12, 15].sample
    end
  end
end

puts "✅ Seeds completados!"
puts "\nUsuarios de prueba creados:"
puts "  - Básico: basico@test.com / password123"
puts "  - Intermedio: intermedio@test.com / password123"
puts "  - Avanzado: avanzado@test.com / password123"
puts "  - Admin: admin@pilates.com / admin123"
