# Phoenix Framework

Este directorio contiene ejemplos conceptuales sobre Phoenix, el framework web de Elixir.

## Que es Phoenix?

Phoenix es un framework web para Elixir que permite crear aplicaciones web modernas, rapidas y mantenibles. Esta inspirado en Ruby on Rails pero aprovecha las ventajas de Elixir y la BEAM.

## Caracteristicas Principales

- **Rendimiento**: Muy rapido gracias a Elixir/BEAM
- **Tiempo real**: WebSockets y canales integrados
- **LiveView**: UI reactiva sin JavaScript
- **Productividad**: Generadores y convenciones claras
- **Escalabilidad**: Hereda la escalabilidad de Erlang/OTP

## Arquitectura

```
Request HTTP
     |
     v
+--------------------+
|     Endpoint       |  Punto de entrada
+--------------------+
     |
     v
+--------------------+
|      Router        |  Ruteo + Pipelines
+--------------------+
     |
     v
+--------------------+
|    Controller      |  Maneja request
|    o LiveView      |  (o LiveView para UI reactiva)
+--------------------+
     |
     v
+--------------------+
|     Context        |  Logica de negocio
+--------------------+
     |
     v
+--------------------+
|    Ecto + Repo     |  Acceso a datos
+--------------------+
     |
     v
   Database
```

## Contenido

### 01_mix_estructura.exs
Fundamentos de Mix y estructura de proyectos:
- Crear proyectos con `mix phx.new`
- Estructura de directorios
- Comandos esenciales
- Configuracion

### 02_ecto.exs
Base de datos con Ecto:
- Migraciones
- Schemas
- Changesets y validacion
- Queries
- Relaciones
- Transacciones

### 03_router_controllers.exs
Manejo de requests:
- Definicion de rutas
- Pipelines
- Controllers y acciones
- Conn (conexion)
- APIs JSON

### 04_templates.exs
Vistas y templates HEEx:
- Sintaxis HEEx
- Componentes
- Formularios
- Layouts
- Helpers

### 05_liveview.exs
Interfaces reactivas sin JavaScript:
- Estructura de LiveView
- Eventos
- Estado con assigns
- Navegacion
- Live Components
- PubSub para tiempo real
- Uploads

### 06_plugs.exs
Middleware en Phoenix:
- Function plugs
- Module plugs
- Pipelines
- Autenticacion
- Plugs personalizados

### 07_contexts.exs
Organizacion del codigo:
- Separacion de capas
- Estructura de contexts
- Generadores
- Testing

## Orden de Aprendizaje Sugerido

1. **Mix y Estructura** - Entender como crear y organizar proyectos
2. **Router y Controllers** - Request/Response basico
3. **Templates** - Renderizar HTML
4. **Ecto** - Persistencia de datos
5. **Contexts** - Organizacion de codigo
6. **LiveView** - UI reactiva
7. **Plugs** - Middleware y autenticacion

## Crear tu Primer Proyecto

```bash
# 1. Instalar Phoenix
mix archive.install hex phx_new

# 2. Crear proyecto
mix phx.new mi_app
cd mi_app

# 3. Configurar base de datos (config/dev.exs)
# Editar credenciales de PostgreSQL

# 4. Setup inicial
mix setup

# 5. Iniciar servidor
mix phx.server

# 6. Visitar http://localhost:4000
```

## Generadores Utiles

```bash
# CRUD con HTML
mix phx.gen.html Accounts User users name:string email:string

# CRUD con LiveView
mix phx.gen.live Accounts User users name:string email:string

# API JSON
mix phx.gen.json Api User users name:string email:string

# Autenticacion completa
mix phx.gen.auth Accounts User users

# Solo context (sin web)
mix phx.gen.context Accounts User users name:string

# Ver todas las rutas
mix phx.routes
```

## Recursos Adicionales

- [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)
- [Ecto](https://hexdocs.pm/ecto)
- [Phoenix Forum](https://elixirforum.com/c/phoenix-forum)

## Nota

Estos archivos son **conceptuales** - muestran ejemplos de codigo pero no son ejecutables directamente. Para practicar, crea un proyecto Phoenix real con `mix phx.new` y experimenta con el codigo.
