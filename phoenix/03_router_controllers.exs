# ==========================================
# ROUTER Y CONTROLLERS EN PHOENIX
# ==========================================
#
# El Router define las rutas de la aplicacion y las
# conecta con los controllers que procesan las requests.

# ==========================================
# ROUTER BASICO
# ==========================================

IO.puts("=== ROUTER ===")

IO.puts("""
# lib/mi_app_web/router.ex

defmodule MiAppWeb.Router do
  use MiAppWeb, :router

  # ================
  # PIPELINES
  # ================

  # Pipeline para navegadores (HTML)
  pipeline :browser do
    plug :accepts, [\"html\"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MiAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # Pipeline para APIs (JSON)
  pipeline :api do
    plug :accepts, [\"json\"]
  end

  # ================
  # SCOPES
  # ================

  # Rutas para navegador
  scope \"/\", MiAppWeb do
    pipe_through :browser

    get \"/\", PageController, :home
    get \"/about\", PageController, :about

    # Rutas RESTful
    resources \"/users\", UserController
    resources \"/posts\", PostController, only: [:index, :show]
    resources \"/comments\", CommentController, except: [:delete]
  end

  # Rutas para API
  scope \"/api\", MiAppWeb.Api, as: :api do
    pipe_through :api

    resources \"/users\", UserController
    resources \"/posts\", PostController
  end

  # Rutas con prefijo de version
  scope \"/api/v1\", MiAppWeb.Api.V1, as: :api_v1 do
    pipe_through :api

    resources \"/products\", ProductController
  end
end
""")

# ==========================================
# RUTAS EN DETALLE
# ==========================================

IO.puts("\n=== TIPOS DE RUTAS ===")

IO.puts("""
# ================
# RUTAS SIMPLES
# ================

get \"/\", PageController, :home
post \"/login\", SessionController, :create
put \"/users/:id\", UserController, :update
patch \"/users/:id\", UserController, :update
delete \"/users/:id\", UserController, :delete

# ================
# RESOURCES (RESTful)
# ================

# Genera 7 rutas automaticamente:
resources \"/users\", UserController

# Equivalente a:
# GET     /users           UserController :index
# GET     /users/:id       UserController :show
# GET     /users/new       UserController :new
# POST    /users           UserController :create
# GET     /users/:id/edit  UserController :edit
# PUT     /users/:id       UserController :update
# PATCH   /users/:id       UserController :update
# DELETE  /users/:id       UserController :delete

# Limitar acciones
resources \"/posts\", PostController, only: [:index, :show]
resources \"/comments\", CommentController, except: [:delete]

# ================
# RECURSOS ANIDADOS
# ================

resources \"/users\", UserController do
  resources \"/posts\", PostController
end

# Genera rutas como:
# GET /users/:user_id/posts
# GET /users/:user_id/posts/:id

# ================
# RUTAS CON PARAMETROS
# ================

# Parametro basico
get \"/users/:id\", UserController, :show
# params[\"id\"] en el controller

# Multiples parametros
get \"/users/:user_id/posts/:id\", PostController, :show

# Parametro glob (captura todo)
get \"/files/*path\", FileController, :show
# /files/a/b/c.txt -> params[\"path\"] = [\"a\", \"b\", \"c.txt\"]

# ================
# HELPERS DE RUTAS
# ================

# Phoenix genera helpers automaticamente
# Usar ~p sigil (verificado en compilacion)

~p\"/users\"                    # \"/users\"
~p\"/users/\#{user}\"           # \"/users/123\"
~p\"/users/\#{user}/edit\"      # \"/users/123/edit\"
~p\"/posts?\#{[page: 2]}\"      # \"/posts?page=2\"

# Ver todas las rutas:
# mix phx.routes
""")

# ==========================================
# CONTROLLERS
# ==========================================

IO.puts("\n=== CONTROLLERS ===")

IO.puts("""
# lib/mi_app_web/controllers/user_controller.ex

defmodule MiAppWeb.UserController do
  use MiAppWeb, :controller

  alias MiApp.Accounts
  alias MiApp.Accounts.User

  # ================
  # ACCIONES BASICAS
  # ================

  # GET /users
  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  # GET /users/:id
  def show(conn, %{\"id\" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  # GET /users/new
  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, :new, changeset: changeset)
  end

  # POST /users
  def create(conn, %{\"user\" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, \"Usuario creado exitosamente.\")
        |> redirect(to: ~p\"/users/\#{user}\")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  # GET /users/:id/edit
  def edit(conn, %{\"id\" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, :edit, user: user, changeset: changeset)
  end

  # PUT/PATCH /users/:id
  def update(conn, %{\"id\" => id, \"user\" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, \"Usuario actualizado.\")
        |> redirect(to: ~p\"/users/\#{user}\")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  # DELETE /users/:id
  def delete(conn, %{\"id\" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> put_flash(:info, \"Usuario eliminado.\")
    |> redirect(to: ~p\"/users\")
  end
end
""")

# ==========================================
# CONN - EL OBJETO DE CONEXION
# ==========================================

IO.puts("\n=== CONN ===")

IO.puts("""
# conn es una estructura Plug.Conn
# Contiene TODO sobre el request y response

# ================
# LEER DEL REQUEST
# ================

# Params (query string, body, path params)
conn.params              # %{\"id\" => \"1\", \"name\" => \"Juan\"}
conn.params[\"id\"]

# Path
conn.request_path        # \"/users/1\"
conn.path_info           # [\"users\", \"1\"]

# Method
conn.method              # \"GET\", \"POST\", etc

# Headers
get_req_header(conn, \"content-type\")
get_req_header(conn, \"authorization\")

# Session
get_session(conn, :user_id)

# ================
# MODIFICAR RESPONSE
# ================

# Headers
conn = put_resp_header(conn, \"x-custom\", \"value\")

# Status
conn = put_status(conn, :not_found)  # 404
conn = put_status(conn, 201)

# Session
conn = put_session(conn, :user_id, 123)
conn = delete_session(conn, :user_id)

# Flash messages
conn = put_flash(conn, :info, \"Exito!\")
conn = put_flash(conn, :error, \"Error!\")

# ================
# RESPONDER
# ================

# Renderizar template
render(conn, :show, user: user)

# Redirect
redirect(conn, to: \"/users\")
redirect(conn, to: ~p\"/users/\#{user}\")
redirect(conn, external: \"https://google.com\")

# JSON
json(conn, %{status: \"ok\", data: user})

# Texto plano
text(conn, \"Hello World\")

# HTML directo
html(conn, \"<h1>Hello</h1>\")

# Enviar archivo
send_download(conn, {:file, \"path/to/file.pdf\"})

# Status sin body
send_resp(conn, 204, \"\")
""")

# ==========================================
# CONTROLLER PARA API JSON
# ==========================================

IO.puts("\n=== CONTROLLER API ===")

IO.puts("""
# lib/mi_app_web/controllers/api/user_controller.ex

defmodule MiAppWeb.Api.UserController do
  use MiAppWeb, :controller

  alias MiApp.Accounts

  action_fallback MiAppWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{\"id\" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def create(conn, %{\"user\" => user_params}) do
    with {:ok, user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(\"location\", ~p\"/api/users/\#{user}\")
      |> render(:show, user: user)
    end
  end

  def update(conn, %{\"id\" => id, \"user\" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{\"id\" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, _} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, \"\")
    end
  end
end

# ----------------------------------------
# JSON View

# lib/mi_app_web/controllers/api/user_json.ex

defmodule MiAppWeb.Api.UserJSON do
  alias MiApp.Accounts.User

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end

# ----------------------------------------
# Fallback Controller (manejo de errores)

defmodule MiAppWeb.FallbackController do
  use MiAppWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: MiAppWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: MiAppWeb.ErrorJSON)
    |> render(:\"404\")
  end
end
""")

# ==========================================
# PATTERN MATCHING EN PARAMS
# ==========================================

IO.puts("\n=== PATTERN MATCHING ===")

IO.puts("""
# Pattern matching en la firma de la funcion

# Extraer parametros especificos
def show(conn, %{\"id\" => id}) do
  # id ya extraido
end

# Con mas parametros
def index(conn, %{\"page\" => page, \"per_page\" => per_page}) do
  # paginacion
end

# Parametros opcionales
def index(conn, params) do
  page = Map.get(params, \"page\", \"1\")
  per_page = Map.get(params, \"per_page\", \"10\")
end

# Matchear formato
def show(conn, %{\"id\" => id, \"format\" => \"json\"}) do
  json(conn, data)
end

def show(conn, %{\"id\" => id}) do
  render(conn, :show)
end
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
ROUTER:
  scope      - agrupar rutas
  pipe_through - aplicar pipeline
  resources  - rutas RESTful
  get/post/put/delete - rutas individuales

CONTROLLER:
  render     - renderizar template
  redirect   - redirigir
  json       - responder JSON
  put_flash  - mensaje flash
  put_status - codigo HTTP

CONN:
  conn.params    - parametros
  get_session    - leer session
  put_session    - escribir session
  put_flash      - flash message

VER RUTAS:
  mix phx.routes

SIGUIENTE: ver 04_templates.exs
""")
