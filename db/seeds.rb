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
def find_or_create_user!(
  email:,
  password:,
  role:,
  level: :basic,
  class_type: :grupal,
  dni: nil,
  mobile: nil,
  phone: nil,
  name: nil,
  join_date: nil,
  subscription_start: nil,
  subscription_end: nil,
  monthly_turns: nil,
  payment_amount: nil,
  debt_amount: nil,
  last_payment_date: nil,
  billing_status: nil
)
  user = User.find_or_initialize_by(email: email)
  user.password = password if user.new_record?
  user.password_confirmation = password if user.new_record?
  user.role = role
  user.level = level
  user.class_type = class_type
  user.dni = dni if dni.present?
  user.mobile = mobile if mobile.present?
  user.phone = phone if phone.present?
  user.name = name if name.present?
  user.join_date = join_date if join_date.present?
  user.subscription_start = subscription_start if subscription_start.present?
  user.subscription_end = subscription_end if subscription_end.present?
  user.monthly_turns = monthly_turns if monthly_turns.present?
  user.payment_amount = payment_amount if payment_amount.present?
  user.debt_amount = debt_amount if debt_amount.present?
  user.last_payment_date = last_payment_date if last_payment_date.present?
  user.billing_status = billing_status if billing_status.present?
  user.save!
  user
end

instructor_user_1 = find_or_create_user!(
  email: "maria.garcia@pilates.com",
  password: "password123",
  role: :instructor,
  level: :advanced,
  class_type: :grupal,
  dni: "20000001",
  mobile: "+54 11 6000 0001"
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
  class_type: :grupal,
  dni: "20000002",
  mobile: "+54 11 6000 0002"
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
  class_type: :grupal,
  dni: "20000003",
  mobile: "+54 11 6000 0003"
)
instructor3 = Instructor.find_or_initialize_by(email: instructor_user_3.email)
instructor3.name = "Ana Martínez"
instructor3.phone = "+34 600 345 678"
instructor3.user = instructor_user_3
instructor3.save!

# Crear Usuarios de prueba
puts "Creando usuarios..."
month_start = Date.current.beginning_of_month
month_end = Date.current.end_of_month

user_inicial = find_or_create_user!(
  email: "inicial@test.com",
  password: "password123",
  role: :alumno,
  level: :inicial,
  class_type: :grupal,
  dni: "30000001",
  mobile: "+54 11 7000 0001",
  name: "Alumno Inicial",
  join_date: month_start - 2.months,
  subscription_start: month_start,
  subscription_end: month_end,
  monthly_turns: 8,
  payment_amount: 30000,
  billing_status: :pendiente
)
user_inicial.update!(birth_date: Date.new(1995, 1, 10)) if user_inicial.birth_date.blank?

user_basic = find_or_create_user!(
  email: "basico@test.com",
  password: "password123",
  role: :alumno,
  level: :basic,
  class_type: :grupal,
  dni: "30000002",
  mobile: "+54 11 7000 0002",
  name: "Alumno Basic",
  join_date: month_start - 5.months,
  subscription_start: month_start,
  subscription_end: month_end,
  monthly_turns: 12,
  payment_amount: 42000,
  last_payment_date: Date.current - 2.days,
  billing_status: :abonado
)
user_basic.update!(birth_date: Date.new(1992, 6, 22)) if user_basic.birth_date.blank?

user_intermediate = find_or_create_user!(
  email: "intermedio@test.com",
  password: "password123",
  role: :alumno,
  level: :intermediate,
  class_type: :grupal,
  dni: "30000003",
  mobile: "+54 11 7000 0003",
  name: "Alumno Intermedio",
  join_date: month_start - 1.year,
  subscription_start: month_start,
  subscription_end: month_end,
  monthly_turns: 16,
  payment_amount: 52000,
  billing_status: :pendiente
)
user_intermediate.update!(birth_date: Date.new(1989, 11, 5)) if user_intermediate.birth_date.blank?

user_advanced = find_or_create_user!(
  email: "avanzado@test.com",
  password: "password123",
  role: :alumno,
  level: :advanced,
  class_type: :grupal,
  dni: "30000004",
  mobile: "+54 11 7000 0004",
  name: "Alumno Avanzado",
  join_date: month_start - 10.months,
  subscription_start: month_start,
  subscription_end: month_end,
  monthly_turns: 20,
  payment_amount: 60000,
  debt_amount: 15000,
  billing_status: :deudor
)

# Usuario con clase privada (patología/lesión)
user_privada = find_or_create_user!(
  email: "privada@test.com",
  password: "password123",
  role: :alumno,
  level: :basic,
  class_type: :privada,
  dni: "30000005",
  mobile: "+54 11 7000 0005",
  name: "Alumno Privada",
  join_date: month_start - 3.months,
  subscription_start: month_start,
  subscription_end: month_end,
  monthly_turns: 8,
  payment_amount: 70000,
  billing_status: :pendiente
)

# Alumno que arranca "medio mes" (para probar fecha de ingreso y cuotas parciales)
user_medio_mes = find_or_create_user!(
  email: "medio_mes@test.com",
  password: "password123",
  role: :alumno,
  level: :basic,
  class_type: :grupal,
  dni: "30000006",
  mobile: "+54 11 7000 0006",
  name: "Alumno Medio Mes",
  join_date: month_start + 14.days,
  subscription_start: month_start + 14.days,
  subscription_end: month_end,
  monthly_turns: 6,
  payment_amount: 24000,
  billing_status: :pendiente
)

# Permite cargar emails reales (sin commitearlos). Ej:
# SEED_REAL_EMAILS="tu@mail.com,amiga@mail.com" bin/rails db:seed
real_emails = ENV["SEED_REAL_EMAILS"].to_s.split(",").map { |e| e.strip.downcase }.reject(&:blank?).uniq
real_students = real_emails.map.with_index do |email, i|
  find_or_create_user!(
    email: email,
    password: ENV["SEED_REAL_PASSWORD"].presence || "password123",
    role: :alumno,
    level: (i.even? ? :basic : :intermediate),
    class_type: :grupal,
    name: "Alumno #{email.split('@').first.to_s.tr('.', ' ').split.map(&:capitalize).join(' ')}",
    join_date: month_start - (i % 6).months,
    subscription_start: month_start,
    subscription_end: month_end,
    monthly_turns: (i.even? ? 12 : 16),
    payment_amount: (i.even? ? 42000 : 52000),
    billing_status: :pendiente
  )
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
  admin.dni ||= "10000000" if Rails.env.development?
  admin.mobile ||= "+54 11 5000 0000" if Rails.env.development?
  admin.save!
end

# Crear Créditos para usuarios (mensuales)
puts "Creando créditos..."
seed_students = [ user_inicial, user_basic, user_intermediate, user_advanced, user_privada, user_medio_mes ] + real_students
seed_students.each do |user|
  # Créditos para el mes actual (vencen al final del mes actual)
  current_month_end = Date.current.end_of_month
  Credit.find_or_create_by!(user: user, expires_at: current_month_end) do |c|
    c.amount = user.monthly_turns.presence || 10
    c.used = false
  end

  # Créditos para el mes siguiente (vencen al final del mes siguiente)
  next_month_end = Date.current.next_month.end_of_month
  Credit.find_or_create_by!(user: user, expires_at: next_month_end) do |c|
    c.amount = [ (user.monthly_turns.presence || 10) - 2, 4 ].max
    c.used = false
  end
end

# Pagos / Caja: generar movimientos realistas y cuotas del mes
puts "Creando pagos de ejemplo..."
due_day = 10
seed_students.each do |user|
  # Cuota del mes actual
  Payment.find_or_create_by!(user: user, kind: :subscription_fee, period_start: month_start, period_end: month_end) do |p|
    p.amount = user.payment_amount.presence || 30000
    p.payment_method = :transferencia
    p.due_date = month_start.change(day: due_day)
    p.turns_included = user.monthly_turns
    p.notes = "Cuota mensual (seed)"
    p.payment_status = (user.billing_status.to_s == "abonado") ? :completed : :pending
    p.paid_at = (p.payment_status == "completed") ? Time.current : nil
  end

  # Extra: algún pago manual / efectivo para ver métodos
  next unless user.email.in?(["basico@test.com", "avanzado@test.com"])

  Payment.create!(
    user: user,
    kind: :manual,
    amount: 5000,
    payment_method: :efectivo,
    payment_status: :completed,
    transaction_id: "seed-#{SecureRandom.hex(3)}"
  )
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

# Crear turnos fijos + clases repetidas del mes para que el dashboard muestre "clases fijas"
puts "Creando turnos fijos..."
fixed_definitions = [
  { user: user_basic, days: [1, 3], hour: 18, level: :basic, room: room2, instructor: instructor1 }, # Lun/Mié 18
  { user: user_intermediate, days: [2, 4], hour: 19, level: :intermediate, room: room3, instructor: instructor2 }, # Mar/Jue 19
  { user: user_advanced, days: [1, 3], hour: 17, level: :advanced, room: room2, instructor: instructor3 } # Lun/Mié 17
].select { |h| h[:user].present? }

fixed_definitions.each do |fd|
  fd[:days].each do |dow|
    FixedSlot.find_or_create_by!(user: fd[:user], day_of_week: dow, hour: fd[:hour]) do |fs|
      fs.status = :active
      fs.room = fd[:room]
      fs.instructor = fd[:instructor]
      fs.level = fd[:level].to_s
    end
  end
end

puts "Creando clases del mes para los turnos fijos..."
fixed_definitions.each do |fd|
  (month_start..month_end).each do |date|
    next unless fd[:days].include?(date.wday)

    start_time = Time.zone.parse("#{date} #{fd[:hour]}:00")
    end_time = start_time + 1.hour
    next unless room_available?(room: fd[:room], start_time: start_time, end_time: end_time)

    PilatesClass.create!(
      name: "Clase #{fd[:level].to_s.capitalize} - #{date.strftime('%d/%m')} #{fd[:hour]}:00",
      start_time: start_time,
      end_time: end_time,
      room: fd[:room],
      instructor: fd[:instructor],
      level: fd[:level],
      class_type: :grupal,
      max_capacity: fd[:room].capacity.presence || 10
    )
  rescue ActiveRecord::RecordInvalid
    # Si ya existe por otra seed/validación de superposición, seguimos.
    next
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
