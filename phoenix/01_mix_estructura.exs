# ==========================================
# MIX Y ESTRUCTURA DE PROYECTOS PHOENIX
# ==========================================
#
# Mix es la herramienta de build de Elixir.
# Phoenix usa Mix para todo: crear proyectos, compilar,
# manejar dependencias, correr tests, etc.
#
# NOTA: Este archivo es conceptual. Para ejecutar Phoenix
# necesitas crear un proyecto real con mix phx.new

# ==========================================
# CREAR UN PROYECTO PHOENIX
# ==========================================

IO.puts("=== CREAR PROYECTO ===")

IO.puts("""
# Instalar Phoenix (una sola vez)
mix archive.install hex phx_new

# Crear proyecto nuevo
mix phx.new mi_app

# Opciones comunes:
mix phx.new mi_app --no-ecto      # sin base de datos
mix phx.new mi_app --no-html      # solo API (sin templates)
mix phx.new mi_app --no-live      # sin LiveView
mix phx.new mi_app --database mysql  # usar MySQL en vez de Postgres

# Despues de crear:
cd mi_app
mix setup        # instala deps, crea DB, corre migraciones
mix phx.server   # inicia el servidor en localhost:4000
""")

# ==========================================
# ESTRUCTURA DE DIRECTORIOS
# ==========================================

IO.puts("\n=== ESTRUCTURA DE DIRECTORIOS ===")

IO.puts("""
mi_app/
|-- lib/
|   |-- mi_app/                    # LOGICA DE NEGOCIO
|   |   |-- application.ex         # Supervision tree
|   |   |-- repo.ex                # Conexion a DB
|   |   |-- accounts/              # Context: Accounts
|   |   |   |-- user.ex            # Schema User
|   |   |   |-- accounts.ex        # Funciones de accounts
|   |   |-- blog/                  # Context: Blog
|   |       |-- post.ex
|   |       |-- blog.ex
|   |
|   |-- mi_app_web/                # CAPA WEB
|       |-- endpoint.ex            # Entry point HTTP
|       |-- router.ex              # Rutas
|       |-- controllers/           # Controllers
|       |   |-- page_controller.ex
|       |   |-- user_controller.ex
|       |-- live/                  # LiveViews
|       |   |-- counter_live.ex
|       |-- components/            # Componentes reutilizables
|       |   |-- layouts.ex         # Layouts
|       |   |-- core_components.ex # Componentes UI
|       |-- gettext.ex             # Internacionalizacion
|
|-- priv/
|   |-- repo/
|   |   |-- migrations/            # Migraciones de DB
|   |   |-- seeds.exs              # Datos iniciales
|   |-- static/                    # Assets estaticos
|       |-- images/
|       |-- favicon.ico
|
|-- assets/                        # Frontend (CSS, JS)
|   |-- css/
|   |-- js/
|   |-- tailwind.config.js
|
|-- test/                          # Tests
|   |-- mi_app/
|   |-- mi_app_web/
|   |-- support/
|
|-- config/                        # Configuracion
|   |-- config.exs                 # Config base
|   |-- dev.exs                    # Config desarrollo
|   |-- test.exs                   # Config tests
|   |-- prod.exs                   # Config produccion
|   |-- runtime.exs                # Config en runtime
|
|-- mix.exs                        # Definicion del proyecto
|-- mix.lock                       # Lock de dependencias
""")

# ==========================================
# MIX.EXS - DEFINICION DEL PROYECTO
# ==========================================

IO.puts("\n=== MIX.EXS ===")

IO.puts("""
# mix.exs define tu proyecto

defmodule MiApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :mi_app,
      version: \"0.1.0\",
      elixir: \"~> 1.14\",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {MiApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Paths de compilacion por ambiente
  defp elixirc_paths(:test), do: [\"lib\", \"test/support\"]
  defp elixirc_paths(_), do: [\"lib\"]

  # DEPENDENCIAS
  defp deps do
    [
      {:phoenix, \"~> 1.7\"},
      {:phoenix_ecto, \"~> 4.4\"},
      {:ecto_sql, \"~> 3.10\"},
      {:postgrex, \">= 0.0.0\"},
      {:phoenix_html, \"~> 4.0\"},
      {:phoenix_live_reload, \"~> 1.4\", only: :dev},
      {:phoenix_live_view, \"~> 0.20\"},
      {:floki, \">= 0.30.0\", only: :test},
      {:esbuild, \"~> 0.8\", runtime: Mix.env() == :dev},
      {:tailwind, \"~> 0.2\", runtime: Mix.env() == :dev},
      {:swoosh, \"~> 1.5\"},           # Emails
      {:finch, \"~> 0.13\"},           # HTTP client
      {:telemetry_metrics, \"~> 0.6\"}, # Metricas
      {:jason, \"~> 1.2\"},            # JSON
      {:plug_cowboy, \"~> 2.5\"}       # Servidor HTTP
    ]
  end

  # ALIASES - comandos personalizados
  defp aliases do
    [
      setup: [\"deps.get\", \"ecto.setup\", \"assets.setup\"],
      \"ecto.setup\": [\"ecto.create\", \"ecto.migrate\", \"run priv/repo/seeds.exs\"],
      \"ecto.reset\": [\"ecto.drop\", \"ecto.setup\"],
      test: [\"ecto.create --quiet\", \"ecto.migrate --quiet\", \"test\"],
      \"assets.setup\": [\"tailwind.install --if-missing\", \"esbuild.install --if-missing\"]
    ]
  end
end
""")

# ==========================================
# COMANDOS MIX ESENCIALES
# ==========================================

IO.puts("\n=== COMANDOS MIX ===")

IO.puts("""
# PROYECTO
mix new mi_app            # proyecto Elixir basico
mix phx.new mi_app        # proyecto Phoenix

# DEPENDENCIAS
mix deps.get              # descargar dependencias
mix deps.update --all     # actualizar todas
mix deps.compile          # compilar dependencias

# BASE DE DATOS (Ecto)
mix ecto.create           # crear base de datos
mix ecto.drop             # eliminar base de datos
mix ecto.migrate          # correr migraciones pendientes
mix ecto.rollback         # revertir ultima migracion
mix ecto.reset            # drop + create + migrate
mix ecto.gen.migration nombre  # crear migracion

# GENERADORES PHOENIX
mix phx.gen.html Accounts User users name:string email:string
  # Genera: schema, migration, controller, views, templates

mix phx.gen.json Api User users name:string email:string
  # Genera: para API JSON

mix phx.gen.live Accounts User users name:string email:string
  # Genera: LiveView CRUD completo

mix phx.gen.context Accounts User users name:string
  # Genera: solo context y schema (sin web)

mix phx.gen.schema User users name:string
  # Genera: solo schema y migration

mix phx.gen.auth Accounts User users
  # Genera: sistema de autenticacion completo!

# SERVIDOR
mix phx.server            # iniciar servidor
iex -S mix phx.server     # servidor con IEx (recomendado para dev)

# TESTS
mix test                  # correr todos los tests
mix test test/mi_app_web/controllers/  # tests especificos
mix test --cover          # con cobertura

# OTROS
mix compile               # compilar proyecto
mix format                # formatear codigo
mix phx.routes            # listar todas las rutas
mix phx.digest            # generar assets para produccion
""")

# ==========================================
# CONFIGURACION (config/)
# ==========================================

IO.puts("\n=== CONFIGURACION ===")

IO.puts("""
# config/config.exs - configuracion base (todos los ambientes)

import Config

config :mi_app,
  ecto_repos: [MiApp.Repo]

config :mi_app, MiAppWeb.Endpoint,
  url: [host: \"localhost\"],
  render_errors: [
    formats: [html: MiAppWeb.ErrorHTML, json: MiAppWeb.ErrorJSON]
  ],
  pubsub_server: MiApp.PubSub,
  live_view: [signing_salt: \"abc123\"]

# Importar config del ambiente actual
import_config \"\#{config_env()}.exs\"

# ----------------------------------------
# config/dev.exs - desarrollo

import Config

config :mi_app, MiApp.Repo,
  username: \"postgres\",
  password: \"postgres\",
  hostname: \"localhost\",
  database: \"mi_app_dev\",
  port: 5432,
  pool_size: 10

config :mi_app, MiAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  debug_errors: true,
  code_reloader: true,
  live_reload: [
    patterns: [
      ~r\"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$\",
      ~r\"lib/mi_app_web/(controllers|live|components)/.*(ex|heex)$\"
    ]
  ]

# ----------------------------------------
# config/runtime.exs - configuracion en runtime (produccion)

import Config

if config_env() == :prod do
  database_url = System.get_env(\"DATABASE_URL\") ||
    raise \"DATABASE_URL not set\"

  config :mi_app, MiApp.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env(\"POOL_SIZE\") || \"10\")

  secret_key_base = System.get_env(\"SECRET_KEY_BASE\") ||
    raise \"SECRET_KEY_BASE not set\"

  config :mi_app, MiAppWeb.Endpoint,
    url: [host: System.get_env(\"PHX_HOST\"), port: 443, scheme: \"https\"],
    http: [port: String.to_integer(System.get_env(\"PORT\") || \"4000\")],
    secret_key_base: secret_key_base
end
""")

# ==========================================
# APPLICATION.EX - SUPERVISION TREE
# ==========================================

IO.puts("\n=== APPLICATION.EX ===")

IO.puts("""
# lib/mi_app/application.ex

defmodule MiApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Repositorio Ecto (base de datos)
      MiApp.Repo,

      # PubSub para LiveView y Channels
      {Phoenix.PubSub, name: MiApp.PubSub},

      # Finch HTTP client
      {Finch, name: MiApp.Finch},

      # Endpoint (servidor web) - SIEMPRE al final
      MiAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: MiApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Callback para config changes (hot reload en dev)
  @impl true
  def config_change(changed, _new, removed) do
    MiAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
""")

# ==========================================
# FLUJO DE UNA REQUEST
# ==========================================

IO.puts("\n=== FLUJO DE REQUEST ===")

IO.puts("""
HTTP Request
    |
    v
+-------------------+
|    Endpoint       |  <- Cowboy recibe la conexion
|  (endpoint.ex)    |
+--------+----------+
         |
         v
+-------------------+
|      Router       |  <- Encuentra la ruta, aplica pipelines
|   (router.ex)     |
+--------+----------+
         |
         v
+-------------------+
|      Plugs        |  <- Middleware (auth, session, etc)
+--------+----------+
         |
         v
+-------------------+
|    Controller     |  <- Logica de la accion
| (user_controller) |
+--------+----------+
         |
         v
+-------------------+
|     Context       |  <- Logica de negocio
|   (accounts.ex)   |
+--------+----------+
         |
         v
+-------------------+
|       Repo        |  <- Acceso a base de datos
|    (repo.ex)      |
+-------------------+
         |
         v
     Database

El controller luego renderiza:
- Template HEEx (HTML)
- JSON (API)
- LiveView (WebSocket)
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
COMANDOS CLAVE:
  mix phx.new mi_app     # crear proyecto
  mix setup              # setup inicial
  mix phx.server         # iniciar servidor
  iex -S mix phx.server  # servidor + IEx

ESTRUCTURA:
  lib/mi_app/            # logica de negocio
  lib/mi_app_web/        # capa web
  priv/repo/migrations/  # migraciones DB
  config/                # configuracion

GENERADORES:
  mix phx.gen.html       # CRUD con templates
  mix phx.gen.live       # CRUD con LiveView
  mix phx.gen.auth       # autenticacion completa

SIGUIENTE: ver 02_ecto.exs para base de datos
""")
