# Sistema de Gestión de Clases de Pilates

Sistema completo de gestión de clases, reservas y créditos para un instituto de pilates, desarrollado con Ruby on Rails 8 y Hotwire.

## 🚀 Características

### Para Usuarios
- **Registro y Autenticación**: Sistema de usuarios con niveles (básico, intermedio, avanzado)
- **Mi Actividad**: Visualización de turnos reservados por mes
- **Ver Agenda**: Calendario de clases con filtros por sala y fecha
- **Sistema de Créditos**: Gestión de créditos con fechas de expiración
- **Solicitudes**: 
  - Alertas cuando se liberan cupos
  - Turnos fijos (pendientes de aprobación)
- **Reservas**: Reserva de clases con validación de nivel y disponibilidad

### Para Administradores
- **Panel ActiveAdmin**: Gestión completa de:
  - Usuarios
  - Salas (3 tipos: Planta Alta, Circuito, Planta Baja)
  - Instructores
  - Clases de Pilates
  - Reservas
  - Créditos
  - Solicitudes
  - Pagos

## 🛠️ Tecnologías

- **Ruby**: 3.2.2
- **Rails**: 8.0.2
- **Base de Datos**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Autenticación**: Devise
- **Admin Panel**: ActiveAdmin
- **Autorización**: Pundit

## 📦 Instalación

1. **Clonar el repositorio**
```bash
cd /home/koma/dev/clases-pilates
```

2. **Instalar dependencias**
```bash
bundle install
npm install  # Si es necesario
```

3. **Configurar base de datos**
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. **Iniciar servidor**
```bash
rails server
```

## 👤 Usuarios de Prueba

Después de ejecutar `rails db:seed`:

- **Usuario Básico**: `basico@test.com` / `password123`
- **Usuario Intermedio**: `intermedio@test.com` / `password123`
- **Usuario Avanzado**: `avanzado@test.com` / `password123`
- **Administrador**: `admin@pilates.com` / `admin123`

## 📋 Rutas Principales

- `/` - Página de inicio
- `/dashboard` - Dashboard principal
- `/mi_actividad` - Turnos del mes
- `/agenda` - Calendario de clases
- `/creditos` - Gestión de créditos
- `/requests` - Solicitudes
- `/admin` - Panel de administración

## 🎯 Funcionalidades Implementadas

✅ Sistema de niveles de usuario  
✅ Validación de reservas por nivel  
✅ Sistema de créditos con expiración  
✅ Calendario con filtros  
✅ Reservas y cancelaciones  
✅ Solicitudes de alerta  
✅ Panel de administración completo  
✅ Interfaz responsive con Hotwire  

## 🔜 Pendiente de Implementar

- [ ] Sistema de pagos (tarjeta, QR, señal 50%)
- [ ] Notificaciones en tiempo real cuando se liberan cupos (Action Cable)
- [ ] Vistas personalizadas de Devise
- [ ] Tests automatizados
- [ ] Mejoras en el calendario (vista semanal/mensual)
- [ ] Exportación de reportes
- [ ] Sistema de recordatorios por email

## 📝 Modelos

- **User**: Usuarios con niveles y autenticación
- **Room**: Salas (3 tipos)
- **Instructor**: Instructores
- **PilatesClass**: Clases con horarios y capacidad
- **Reservation**: Reservas de usuarios
- **Credit**: Créditos con expiración
- **Request**: Solicitudes (alertas y turnos fijos)
- **Payment**: Pagos (modelo creado, pendiente implementación)

## 🎨 Estilos

Los estilos están en `app/assets/stylesheets/application.css` y son completamente personalizables.

## 📚 Documentación Adicional

- [Rails Guides](https://guides.rubyonrails.org/)
- [Hotwire Documentation](https://hotwired.dev/)
- [Devise Documentation](https://github.com/heartcombo/devise)
- [ActiveAdmin Documentation](https://activeadmin.info/)

## 🤝 Contribuir

Este es un proyecto en desarrollo. Las contribuciones son bienvenidas.

## 📄 Licencia

Este proyecto es privado y está destinado al uso del instituto de pilates.
