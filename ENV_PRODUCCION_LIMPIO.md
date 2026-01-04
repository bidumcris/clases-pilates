# Template de `.env` para Producción (Versión Limpia)

## Tu `.env` actualizado debería quedar así:

```bash
# =============================================================================
# CONFIGURACIÓN COMPARTIDA (Rails)
# =============================================================================
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=1
RAILS_SERVE_STATIC_FILES=1
RAILS_MAX_THREADS=5
FORCE_SSL=0

# =============================================================================
# PUMA (Servidor Web)
# =============================================================================
BIND=127.0.0.1
PORT=3000

# =============================================================================
# BASE DE DATOS (OPCIÓN 1: DATABASE_URL - RECOMENDADO - MÁS SIMPLE)
# =============================================================================
DATABASE_URL=postgres://clases_pilates:grinco@127.0.0.1:5432/clases_pilates_production

# =============================================================================
# RAILS CREDENTIALS
# =============================================================================
RAILS_MASTER_KEY=85edfe7ac3f8388490c267d446b07eae
```

## O si prefieres usar variables individuales (OPCIÓN 2):

```bash
# =============================================================================
# CONFIGURACIÓN COMPARTIDA (Rails)
# =============================================================================
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=1
RAILS_SERVE_STATIC_FILES=1
RAILS_MAX_THREADS=5
FORCE_SSL=0

# =============================================================================
# PUMA (Servidor Web)
# =============================================================================
BIND=127.0.0.1
PORT=3000

# =============================================================================
# BASE DE DATOS (Variables individuales)
# =============================================================================
DATABASE_NAME=clases_pilates_production
DATABASE_HOST=127.0.0.1
DATABASE_PORT=5432
DATABASE_USERNAME=clases_pilates
DATABASE_PASSWORD=grinco

# =============================================================================
# RAILS CREDENTIALS
# =============================================================================
RAILS_MASTER_KEY=85edfe7ac3f8388490c267d446b07eae
```

## O usando prefijo CLASES_PILATES_ (OPCIÓN 3 - también funciona):

```bash
# =============================================================================
# CONFIGURACIÓN COMPARTIDA (Rails)
# =============================================================================
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=1
RAILS_SERVE_STATIC_FILES=1
RAILS_MAX_THREADS=5
FORCE_SSL=0

# =============================================================================
# PUMA (Servidor Web)
# =============================================================================
BIND=127.0.0.1
PORT=3000

# =============================================================================
# BASE DE DATOS (Con prefijo CLASES_PILATES_)
# =============================================================================
CLASES_PILATES_DATABASE_NAME=clases_pilates_production
CLASES_PILATES_DATABASE_HOST=127.0.0.1
CLASES_PILATES_DATABASE_PORT=5432
CLASES_PILATES_DATABASE_USERNAME=clases_pilates
CLASES_PILATES_DATABASE_PASSWORD=grinco

# =============================================================================
# RAILS CREDENTIALS
# =============================================================================
RAILS_MASTER_KEY=85edfe7ac3f8388490c267d446b07eae
```

## Recomendación

**Usa la OPCIÓN 1 (DATABASE_URL)** porque:
- ✅ Más simple (una sola línea)
- ✅ Estándar de la industria
- ✅ Fácil de mantener
- ✅ Compatible con servicios gestionados (Heroku, AWS, etc.)

## Para actualizar tu `.env` en producción:

```bash
cd ~/apps/pilates
nano .env
```

Copia y pega la **OPCIÓN 1** (la más simple) y reemplaza los valores con los tuyos reales.

