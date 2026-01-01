# Comandos para Resetear y Cargar Seeds

## 1. SUBIR CAMBIOS AL REPOSITORIO

```bash
# Hacer commit de todos los cambios
git commit -m "feat: Panel de gestión personalizado, calendario semanal, créditos mensuales y seeds actualizados

- Agregado panel de gestión personalizado (/management) para admins e instructores
- Implementado calendario semanal navegable con vista por días
- Sistema de créditos mensuales (vencen al final de cada mes)
- Filtrado de clases por nivel y tipo de usuario (grupal/privada)
- Mensaje importante sobre créditos sin usar en dashboard
- Seeds actualizados con clases grupales y privadas
- Agregadas imágenes del manual de marca
- Mejoras en UI/UX con colores de la marca"

# Subir al repositorio
git push origin development
```

## 2. RESETEAR Y CARGAR SEEDS EN LOCAL

```bash
# Opción 1: Resetear completamente la base de datos (RECOMENDADO)
# Esto elimina todas las tablas y las recrea desde cero
RAILS_ENV=development bundle exec rails db:reset

# Opción 2: Solo borrar datos y cargar seeds (más rápido)
RAILS_ENV=development bundle exec rails db:seed:replant

# Opción 3: Borrar datos manualmente y cargar seeds
RAILS_ENV=development bundle exec rails db:drop db:create db:migrate db:seed
```

## 3. RESETEAR Y CARGAR SEEDS EN PRODUCTION

⚠️ **ADVERTENCIA**: Estos comandos eliminarán TODOS los datos de producción. Úsalos con precaución.

**IMPORTANTE**: Rails protege la base de datos de producción. Necesitas usar `DISABLE_DATABASE_ENVIRONMENT_CHECK=1` para ejecutar comandos destructivos.

```bash
# Opción 1: Resetear completamente (RECOMENDADO para producción limpia)
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:reset

# Opción 2: Solo borrar datos y cargar seeds
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:seed:replant

# Opción 3: Borrar datos manualmente y cargar seeds
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:drop db:create db:migrate db:seed
```

## 4. COMANDOS INDIVIDUALES (si necesitas más control)

### Local
```bash
# Borrar solo los datos (sin eliminar tablas)
RAILS_ENV=development bundle exec rails db:truncate_all

# Cargar seeds
RAILS_ENV=development bundle exec rails db:seed
```

### Production
```bash
# Borrar solo los datos (sin eliminar tablas)
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:truncate_all

# Cargar seeds
RAILS_ENV=production bundle exec rails db:seed
```

## 5. VERIFICAR QUE TODO FUNCIONA

```bash
# Verificar usuarios creados
RAILS_ENV=development bundle exec rails runner "puts User.count; puts User.pluck(:email)"

# Verificar clases creadas
RAILS_ENV=development bundle exec rails runner "puts PilatesClass.count"

# Verificar créditos creados
RAILS_ENV=development bundle exec rails runner "puts Credit.count"
```

## NOTAS IMPORTANTES

- **db:reset**: Elimina la base de datos, la recrea, ejecuta migraciones y carga seeds
- **db:seed:replant**: Solo borra datos (no elimina tablas) y carga seeds (Rails 6.1+)
- **db:drop db:create db:migrate db:seed**: Proceso manual paso a paso

### Para Production:
- ⚠️ **CRÍTICO**: Rails protege la base de datos de producción
- Debes usar `DISABLE_DATABASE_ENVIRONMENT_CHECK=1` antes de comandos destructivos
- Asegúrate de tener backups antes de ejecutar estos comandos
- Verifica que las variables de entorno estén configuradas correctamente
- Considera hacer un mantenimiento programado
- Ejemplo completo:
  ```bash
  DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production bundle exec rails db:reset
  ```

