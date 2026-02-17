# ==========================================
# PLUGS EN PHOENIX
# ==========================================
#
# Plug es la especificacion de composicion de modulos web.
# Cada request pasa por una serie de plugs (middleware).
# Phoenix esta construido sobre Plug.

# ==========================================
# QUE ES UN PLUG?
# ==========================================

IO.puts("=== QUE ES UN PLUG ===")

IO.puts("""
Un Plug es una funcion o modulo que:
1. Recibe una conexion (conn)
2. La transforma de alguna manera
3. Retorna la conexion modificada

TIPOS DE PLUGS:
- Function Plug: una funcion con aridad 2
- Module Plug: un modulo que implementa init/1 y call/2

FLUJO:
  Request -> Plug1 -> Plug2 -> Plug3 -> Response
                 |       |       |
              transform transform transform
""")

# ==========================================
# FUNCTION PLUG
# ==========================================

IO.puts("\n=== FUNCTION PLUG ===")

IO.puts("""
# El plug mas simple es una funcion

defmodule MiAppWeb.Router do
  use MiAppWeb, :router

  # Definir plug como funcion privada
  defp log_request(conn, _opts) do
    IO.puts(\"Request: \#{conn.method} \#{conn.request_path}\")
    conn
  end

  defp put_custom_header(conn, _opts) do
    put_resp_header(conn, \"x-custom\", \"value\")
  end

  pipeline :browser do
    plug :accepts, [\"html\"]
    plug :fetch_session
    plug :log_request        # <-- plug funcion
    plug :put_custom_header  # <-- plug funcion
  end
end

# La firma es:
# plug_function(conn, opts) :: conn
""")

# ==========================================
# MODULE PLUG
# ==========================================

IO.puts("\n=== MODULE PLUG ===")

IO.puts("""
# Para plugs mas complejos, usar un modulo

# lib/mi_app_web/plugs/auth.ex
defmodule MiAppWeb.Plugs.Auth do
  import Plug.Conn
  import Phoenix.Controller

  # init/1 se ejecuta en COMPILACION
  # Preprocesa las opciones
  def init(opts) do
    Keyword.get(opts, :redirect_to, \"/login\")
  end

  # call/2 se ejecuta en cada REQUEST
  def call(conn, redirect_to) do
    if get_session(conn, :user_id) do
      conn
    else
      conn
      |> put_flash(:error, \"Debes iniciar sesion\")
      |> redirect(to: redirect_to)
      |> halt()  # IMPORTANTE: detener la cadena de plugs
    end
  end
end

# Uso en router:
pipeline :authenticated do
  plug MiAppWeb.Plugs.Auth, redirect_to: \"/login\"
end

# O en controller:
defmodule MiAppWeb.UserController do
  plug MiAppWeb.Plugs.Auth when action in [:edit, :update, :delete]
end
""")

# ==========================================
# PLUGS COMUNES EN PHOENIX
# ==========================================

IO.puts("\n=== PLUGS COMUNES ===")

IO.puts("""
# ================
# PIPELINE :browser
# ================

pipeline :browser do
  plug :accepts, [\"html\"]          # Solo acepta HTML
  plug :fetch_session              # Carga la sesion
  plug :fetch_live_flash           # Flash messages para LiveView
  plug :put_root_layout, ...       # Layout base
  plug :protect_from_forgery       # CSRF protection
  plug :put_secure_browser_headers # Headers de seguridad
end

# ================
# PIPELINE :api
# ================

pipeline :api do
  plug :accepts, [\"json\"]  # Solo acepta JSON
end

# ================
# PLUG DE SESION
# ================

# Leer sesion
user_id = get_session(conn, :user_id)

# Escribir sesion
conn = put_session(conn, :user_id, user.id)

# Limpiar sesion
conn = clear_session(conn)

# Configurar sesion (nuevo ID)
conn = configure_session(conn, renew: true)

# ================
# PLUG DE FLASH
# ================

# Escribir flash
conn = put_flash(conn, :info, \"Operacion exitosa\")
conn = put_flash(conn, :error, \"Algo fallo\")

# Leer flash (en template)
# @flash[\"info\"], @flash[\"error\"]
""")

# ==========================================
# PLUGS PERSONALIZADOS COMUNES
# ==========================================

IO.puts("\n=== EJEMPLOS DE PLUGS ===")

IO.puts("""
# ================
# PLUG DE AUTENTICACION
# ================

defmodule MiAppWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, \"Acceso denegado\")
      |> redirect(to: \"/login\")
      |> halt()
    end
  end
end

# ================
# PLUG PARA CARGAR USUARIO
# ================

defmodule MiAppWeb.Plugs.LoadUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = MiApp.Accounts.get_user(user_id)
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end
end

# Usar en router:
pipeline :browser do
  # ... otros plugs
  plug MiAppWeb.Plugs.LoadUser
end

# ================
# PLUG DE ROLES
# ================

defmodule MiAppWeb.Plugs.RequireRole do
  import Plug.Conn
  import Phoenix.Controller

  def init(role), do: role

  def call(conn, required_role) do
    user = conn.assigns[:current_user]

    if user && user.role == required_role do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> put_view(MiAppWeb.ErrorHTML)
      |> render(:\"403\")
      |> halt()
    end
  end
end

# Uso:
plug MiAppWeb.Plugs.RequireRole, :admin

# ================
# PLUG DE RATE LIMITING
# ================

defmodule MiAppWeb.Plugs.RateLimit do
  import Plug.Conn

  def init(opts) do
    %{
      max_requests: Keyword.get(opts, :max, 100),
      window_ms: Keyword.get(opts, :window, 60_000)
    }
  end

  def call(conn, %{max_requests: max, window_ms: window}) do
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    key = \"rate_limit:\#{ip}\"

    case check_rate(key, max, window) do
      :ok ->
        conn
      :rate_limited ->
        conn
        |> put_status(:too_many_requests)
        |> put_resp_header(\"retry-after\", \"60\")
        |> send_resp(429, \"Too many requests\")
        |> halt()
    end
  end

  defp check_rate(key, max, window) do
    # Implementar con ETS, Redis, etc.
    :ok
  end
end

# ================
# PLUG DE LOGGING
# ================

defmodule MiAppWeb.Plugs.RequestLogger do
  require Logger
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    start = System.monotonic_time()

    Plug.Conn.register_before_send(conn, fn conn ->
      stop = System.monotonic_time()
      diff = System.convert_time_unit(stop - start, :native, :millisecond)

      Logger.info(
        \"\#{conn.method} \#{conn.request_path} - \#{conn.status} in \#{diff}ms\"
      )

      conn
    end)
  end
end
""")

# ==========================================
# PLUG EN CONTROLLERS
# ==========================================

IO.puts("\n=== PLUG EN CONTROLLERS ===")

IO.puts("""
defmodule MiAppWeb.UserController do
  use MiAppWeb, :controller

  # Plug para todas las acciones
  plug MiAppWeb.Plugs.RequireAuth

  # Plug solo para algunas acciones
  plug MiAppWeb.Plugs.RequireRole, :admin when action in [:delete]

  # Plug excepto algunas acciones
  plug :load_user when action not in [:index, :new]

  # Plug funcion local
  defp load_user(conn, _opts) do
    id = conn.params[\"id\"]
    user = MiApp.Accounts.get_user!(id)
    assign(conn, :user, user)
  end

  def show(conn, _params) do
    # @user ya esta cargado por el plug
    render(conn, :show, user: conn.assigns.user)
  end

  def delete(conn, _params) do
    # Solo admins llegan aqui
    MiApp.Accounts.delete_user(conn.assigns.user)
    redirect(conn, to: ~p\"/users\")
  end
end
""")

# ==========================================
# HALT - DETENER LA CADENA
# ==========================================

IO.puts("\n=== HALT ===")

IO.puts("""
# halt/1 detiene la ejecucion de los siguientes plugs

def call(conn, _opts) do
  if unauthorized?(conn) do
    conn
    |> send_resp(401, \"Unauthorized\")
    |> halt()  # No ejecutar mas plugs ni el controller
  else
    conn
  end
end

# SIN halt():
# Request -> Plug1 -> Plug2 -> Controller -> Response

# CON halt() en Plug1:
# Request -> Plug1 -> Response
#                  X (no llega a Plug2 ni Controller)

# IMPORTANTE: Siempre usar halt() cuando respondes en un plug
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
TIPOS DE PLUG:
  Function: plug_fn(conn, opts) :: conn
  Module: init/1 + call/2

USAR PLUGS:
  Router: pipeline + pipe_through
  Controller: plug MiPlug when action in [...]

FUNCIONES UTILES:
  assign(conn, :key, value)  - asignar datos
  get_session/put_session    - sesion
  put_flash                  - mensajes flash
  halt()                     - detener cadena

PATRON COMUN:
  1. Verificar condicion
  2. Si OK: pasar conn
  3. Si NO: responder + halt()

SIGUIENTE: ver 07_contexts.exs
""")
