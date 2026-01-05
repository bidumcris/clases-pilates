# Limpiar datos existentes (solo en desarrollo)
if Rails.env.development?
  puts "Limpiando datos existentes..."
  Reservation.destroy_all
  Request.destroy_all
  Credit.destroy_all
  Payment.destroy_all
  FixedSlot.destroy_all if defined?(FixedSlot)
  PilatesClass.destroy_all
  Instructor.destroy_all
  Room.destroy_all
  User.destroy_all
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
def find_or_create_user!(email:, password:, role:, level: :basic, class_type: :grupal)
  user = User.find_or_initialize_by(email: email)
  user.password = password if user.new_record?
  user.password_confirmation = password if user.new_record?
  user.role = role
  user.level = level
  user.class_type = class_type
  user.save!
  user
end

instructor_user_1 = find_or_create_user!(
  email: "maria.garcia@pilates.com",
  password: "password123",
  role: :instructor,
  level: :advanced,
  class_type: :grupal
)
instructor1 = Instructor.find_or_initialize_by(email: instructor_user_1.email)
instructor1.name = "María García"
instructor1.phone = "+34 600 123 456"
instructor1.user = instructor_user_1
instructor1.save!

instructor_user_2 = find_or_create_user!(
  email: "juan.lopez@pilates.com",
  password: "password123",
  role: :instructor,
  level: :advanced,
  class_type: :grupal
)
instructor2 = Instructor.find_or_initialize_by(email: instructor_user_2.email)
instructor2.name = "Juan López"
instructor2.phone = "+34 600 234 567"
instructor2.user = instructor_user_2
instructor2.save!

instructor_user_3 = find_or_create_user!(
  email: "ana.martinez@pilates.com",
  password: "password123",
  role: :instructor,
  level: :advanced,
  class_type: :grupal
)
instructor3 = Instructor.find_or_initialize_by(email: instructor_user_3.email)
instructor3.name = "Ana Martínez"
instructor3.phone = "+34 600 345 678"
instructor3.user = instructor_user_3
instructor3.save!

# Crear Usuarios de prueba
puts "Creando usuarios..."
user_inicial = User.find_or_create_by!(email: "inicial@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :alumno
  u.level = :inicial
  u.class_type = :grupal
end

user_basic = User.find_or_create_by!(email: "basico@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :alumno
  u.level = :basic
  u.class_type = :grupal
end

user_intermediate = User.find_or_create_by!(email: "intermedio@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :alumno
  u.level = :intermediate
  u.class_type = :grupal
end

user_advanced = User.find_or_create_by!(email: "avanzado@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :alumno
  u.level = :advanced
  u.class_type = :grupal
end

# Usuario con clase privada (patología/lesión)
user_privada = User.find_or_create_by!(email: "privada@test.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :alumno
  u.level = :basic
  u.class_type = :privada
end

# Crear Admin
admin_email = ENV["ADMIN_EMAIL"].presence || (Rails.env.development? ? "admin@pilates.com" : nil)
admin_password = ENV["ADMIN_PASSWORD"].presence || (Rails.env.development? ? "admin123" : nil)

admin = nil
if admin_email && admin_password
  admin = User.find_or_initialize_by(email: admin_email)
  admin.password = admin_password if admin.new_record?
  admin.password_confirmation = admin_password if admin.new_record?
  admin.role = :admin
  admin.level = :advanced
  admin.class_type = :grupal
  admin.save!
end

# Crear Créditos para usuarios (mensuales)
puts "Creando créditos..."
[ user_inicial, user_basic, user_intermediate, user_advanced, user_privada ].each do |user|
  # Créditos para el mes actual (vencen al final del mes actual)
  current_month_end = Date.current.end_of_month
  Credit.find_or_create_by!(user: user, expires_at: current_month_end) do |c|
    c.amount = 10
    c.used = false
  end

  # Créditos para el mes siguiente (vencen al final del mes siguiente)
  next_month_end = Date.current.next_month.end_of_month
  Credit.find_or_create_by!(user: user, expires_at: next_month_end) do |c|
    c.amount = 8
    c.used = false
  end
end

# Crear Clases de Pilates
puts "Creando clases de pilates..."
start_date = Date.tomorrow
instructors = [ instructor1, instructor2, instructor3 ]
rooms = [ room1, room2, room3 ]
levels = [ :inicial, :basic, :intermediate, :advanced ]

def room_available?(room:, start_time:, end_time:)
  !PilatesClass.where(room: room).where("start_time < ? AND end_time > ?", end_time, start_time).exists?
end

# Crear clases para las próximas 2 semanas (14 días)
14.times do |day|
  current_date = start_date + day.days

  # Clases grupales por la mañana (9:00, 10:00, 11:00)
  [ 9, 10, 11 ].each do |hour|
    level = levels.sample
    start_time = Time.zone.parse("#{current_date} #{hour}:00")
    end_time = start_time + 1.hour
    room = rooms.shuffle.find { |r| room_available?(room: r, start_time: start_time, end_time: end_time) }
    next unless room
    instructor = instructors.sample

    PilatesClass.find_or_create_by!(
      name: "Clase #{level.to_s.capitalize} - #{current_date.strftime('%d/%m')} #{hour}:00",
      start_time: start_time,
      room: room,
      instructor: instructor
    ) do |pc|
      pc.level = level
      pc.class_type = :grupal
      pc.end_time = end_time
      pc.max_capacity = case room.room_type
      when "planta_alta_privadas"
                          8
      when "circuito"
                          12
      when "planta_baja_mat_accesorios"
                          15
      else
                          10
      end
    end
  end

  # Clases grupales por la tarde (17:00, 18:00, 19:00)
  [ 17, 18, 19 ].each do |hour|
    level = levels.sample
    start_time = Time.zone.parse("#{current_date} #{hour}:00")
    end_time = start_time + 1.hour
    room = rooms.shuffle.find { |r| room_available?(room: r, start_time: start_time, end_time: end_time) }
    next unless room
    instructor = instructors.sample

    PilatesClass.find_or_create_by!(
      name: "Clase #{level.to_s.capitalize} - #{current_date.strftime('%d/%m')} #{hour}:00",
      start_time: start_time,
      room: room,
      instructor: instructor
    ) do |pc|
      pc.level = level
      pc.class_type = :grupal
      pc.end_time = end_time
      pc.max_capacity = case room.room_type
      when "planta_alta_privadas"
                          8
      when "circuito"
                          12
      when "planta_baja_mat_accesorios"
                          15
      else
                          10
      end
    end
  end

  # Crear algunas clases privadas (solo para niveles inicial y basic)
  if day % 2 == 0 # Cada 2 días
    [ 10, 11, 17, 18 ].sample(2).each do |hour|
      level = [ :inicial, :basic ].sample
      # Las clases privadas van en Planta Alta - Privadas
      room_privada = room1
      instructor = instructors.sample
      start_time = Time.zone.parse("#{current_date} #{hour}:00")
      end_time = start_time + 1.hour
      next unless room_available?(room: room_privada, start_time: start_time, end_time: end_time)

      PilatesClass.find_or_create_by!(
        name: "Clase Privada #{level.to_s.capitalize} - #{current_date.strftime('%d/%m')} #{hour}:00",
        start_time: start_time,
        room: room_privada,
        instructor: instructor
      ) do |pc|
        pc.level = level
        pc.class_type = :privada
        pc.end_time = end_time
        pc.max_capacity = 1 # Clases privadas: 1 alumno
      end
    end
  end
end

# Crear algunas reservas de ejemplo
puts "Creando reservas de ejemplo..."
if user_basic && user_intermediate && user_advanced
  # Obtener algunas clases grupales disponibles
  available_classes = PilatesClass.grupal.upcoming.limit(5)

  available_classes.each_with_index do |pilates_class, index|
    user = [ user_basic, user_intermediate, user_advanced ][index % 3]

    # Verificar que el usuario puede reservar esta clase
    if user.can_reserve_class?(pilates_class)
      credit = user.credits.available.first
      if credit && credit.amount > 0
        reservation = Reservation.find_or_create_by!(
          user: user,
          pilates_class: pilates_class
        ) do |r|
          r.status = :confirmed
          r.reserved_at = Time.current
        end

        # Usar 1 crédito
        credit.use!(1) if reservation.persisted?
      end
    end
  end
end

# Crear algunas solicitudes de ejemplo
puts "Creando solicitudes de ejemplo..."
if user_inicial && user_basic
  # Solicitud de alerta (cuando una clase está llena)
  full_class = PilatesClass.grupal.upcoming.first
  if full_class
    Request.find_or_create_by!(
      user: user_inicial,
      pilates_class: full_class,
      request_type: :alert
    ) do |r|
      r.status = :pending
    end
  end

  # Solicitud de turno fijo (pendiente de aprobación)
  future_class = PilatesClass.grupal.upcoming.where(level: :basic).first
  if future_class
    Request.find_or_create_by!(
      user: user_basic,
      pilates_class: future_class,
      request_type: :fixed_slot
    ) do |r|
      r.status = :pending
    end
  end
end

puts "\n✅ Seeds completados!"
puts "\n" + "="*60
puts "USUARIOS DE PRUEBA CREADOS:"
puts "="*60
puts "  📚 Alumnos:"
puts "    • Inicial (Grupal): inicial@test.com / password123"
puts "    • Básico (Grupal): basico@test.com / password123"
puts "    • Intermedio (Grupal): intermedio@test.com / password123"
puts "    • Avanzado (Grupal): avanzado@test.com / password123"
puts "    • Privada (Patología/Lesión): privada@test.com / password123"
puts "\n  👩‍🏫 Instructores:"
puts "    • María: maria.garcia@pilates.com / password123"
puts "    • Juan:  juan.lopez@pilates.com / password123"
puts "    • Ana:   ana.martinez@pilates.com / password123"
puts "\n  👨‍💼 Administrador:"
if admin
  puts "    • Admin: #{admin.email} / #{Rails.env.development? ? 'admin123' : '(definido por ENV)'}"
else
  puts "    • Admin: (no creado — definí ADMIN_EMAIL y ADMIN_PASSWORD para crearlo)"
end
puts "\n" + "="*60
puts "DATOS CREADOS:"
puts "="*60
puts "  • #{Room.count} salas"
puts "  • #{Instructor.count} instructores"
puts "  • #{User.where(role: :alumno).count} alumnos"
puts "  • #{PilatesClass.count} clases (grupales y privadas)"
puts "  • #{Credit.count} créditos mensuales"
puts "  • #{Reservation.count} reservas de ejemplo"
puts "  • #{Request.count} solicitudes de ejemplo"
puts "\n💡 Tip: Las clases privadas solo aparecen para usuarios con class_type: privada"
puts "💡 Tip: Los créditos vencen al final de cada mes"
puts "="*60
