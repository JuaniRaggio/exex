# ==========================================
# CONTEXTS EN PHOENIX
# ==========================================
#
# Los Contexts son modulos que agrupan funcionalidad relacionada.
# Son la API publica para acceder a la logica de negocio.
#
# Separan la capa WEB de la logica de NEGOCIO.

# ==========================================
# POR QUE CONTEXTS?
# ==========================================

IO.puts("=== POR QUE CONTEXTS ===")

IO.puts("""
SIN CONTEXTS (anti-patron):
  Controller -> Repo -> Database
  El controller accede directamente a Ecto

CON CONTEXTS (recomendado):
  Controller -> Context -> Repo -> Database
  El controller NO sabe de Ecto

VENTAJAS:
1. Separacion de responsabilidades
2. Codigo mas testeable
3. API clara y documentada
4. Facil de refactorizar
5. Reutilizable (LiveView, API, tareas, etc)

ESTRUCTURA:
lib/mi_app/
  accounts/              # Context: Accounts
    user.ex              # Schema
    accounts.ex          # API publica
  blog/                  # Context: Blog
    post.ex
    comment.ex
    blog.ex              # API publica
""")

# ==========================================
# ESTRUCTURA DE UN CONTEXT
# ==========================================

IO.puts("\n=== ESTRUCTURA ===")

IO.puts("""
# ================
# SCHEMA (user.ex)
# ================

# lib/mi_app/accounts/user.ex

defmodule MiApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema \"users\" do
    field :name, :string
    field :email, :string
    field :password_hash, :string

    field :password, :string, virtual: true

    has_many :posts, MiApp.Blog.Post

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end

# ================
# CONTEXT (accounts.ex)
# ================

# lib/mi_app/accounts/accounts.ex

defmodule MiApp.Accounts do
  @moduledoc \"\"\"
  El context de Accounts.
  Maneja usuarios y autenticacion.
  \"\"\"

  import Ecto.Query
  alias MiApp.Repo
  alias MiApp.Accounts.User

  # ========== CRUD ==========

  def list_users do
    Repo.all(User)
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  # ========== PARA FORMULARIOS ==========

  def change_user(%User{} = user, attrs \\\\ %{}) do
    User.changeset(user, attrs)
  end

  def change_user_registration(%User{} = user, attrs \\\\ %{}) do
    User.registration_changeset(user, attrs)
  end

  # ========== AUTENTICACION ==========

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :invalid_password}
      true ->
        Bcrypt.no_user_verify()
        {:error, :not_found}
    end
  end

  # ========== QUERIES ESPECIALES ==========

  def list_active_users do
    from(u in User, where: u.active == true)
    |> Repo.all()
  end

  def count_users do
    Repo.aggregate(User, :count)
  end
end
""")

# ==========================================
# USO DEL CONTEXT
# ==========================================

IO.puts("\n=== USO DEL CONTEXT ===")

IO.puts("""
# ================
# EN CONTROLLER
# ================

defmodule MiAppWeb.UserController do
  use MiAppWeb, :controller

  alias MiApp.Accounts  # <-- importar context

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{\"id\" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{\"user\" => params}) do
    case Accounts.create_user(params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, \"Usuario creado\")
        |> redirect(to: ~p\"/users/\#{user}\")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end

# ================
# EN LIVEVIEW
# ================

defmodule MiAppWeb.UserLive.Index do
  use MiAppWeb, :live_view

  alias MiApp.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, users: Accounts.list_users())}
  end
end

# ================
# EN TAREA (mix task)
# ================

defmodule Mix.Tasks.CreateAdmin do
  use Mix.Task

  def run(_args) do
    Mix.Task.run(\"app.start\")

    MiApp.Accounts.register_user(%{
      name: \"Admin\",
      email: \"admin@example.com\",
      password: \"password123\"
    })
  end
end
""")

# ==========================================
# CONTEXT CON RELACIONES
# ==========================================

IO.puts("\n=== RELACIONES ENTRE CONTEXTS ===")

IO.puts("""
# ================
# CONTEXTOS INDEPENDIENTES
# ================

# Cada context tiene sus propias funciones
# Para relaciones, pasar IDs

# lib/mi_app/blog/blog.ex
defmodule MiApp.Blog do
  alias MiApp.Repo
  alias MiApp.Blog.Post

  def create_post(user_id, attrs) do
    %Post{user_id: user_id}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def list_posts_by_user(user_id) do
    from(p in Post, where: p.user_id == ^user_id)
    |> Repo.all()
  end

  # Preload de otra entidad
  def get_post_with_author!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end
end

# ================
# USO EN CONTROLLER
# ================

defmodule MiAppWeb.PostController do
  def create(conn, %{\"post\" => params}) do
    user = conn.assigns.current_user

    case Blog.create_post(user.id, params) do
      {:ok, post} -> redirect(conn, to: ~p\"/posts/\#{post}\")
      {:error, changeset} -> render(conn, :new, changeset: changeset)
    end
  end
end

# ================
# EVITAR DEPENDENCIAS CIRCULARES
# ================

# MAL: Accounts depende de Blog, Blog depende de Accounts

# BIEN: Usar IDs, no estructuras completas
# BIEN: Crear un tercer context si hay logica compartida
""")

# ==========================================
# GENERADORES DE PHOENIX
# ==========================================

IO.puts("\n=== GENERADORES ===")

IO.puts("""
# Phoenix genera contexts automaticamente

# ================
# GENERAR CONTEXT COMPLETO (HTML)
# ================

mix phx.gen.html Accounts User users name:string email:string age:integer

# Genera:
# - lib/mi_app/accounts/user.ex (schema)
# - lib/mi_app/accounts.ex (context)
# - lib/mi_app_web/controllers/user_controller.ex
# - lib/mi_app_web/controllers/user_html.ex
# - lib/mi_app_web/controllers/user_html/*.heex
# - priv/repo/migrations/*_create_users.exs
# - test/mi_app/accounts_test.exs
# - test/mi_app_web/controllers/user_controller_test.exs

# ================
# GENERAR PARA API JSON
# ================

mix phx.gen.json Api User users name:string email:string

# ================
# GENERAR PARA LIVEVIEW
# ================

mix phx.gen.live Accounts User users name:string email:string

# ================
# SOLO CONTEXT (sin web)
# ================

mix phx.gen.context Accounts User users name:string email:string

# ================
# SOLO SCHEMA
# ================

mix phx.gen.schema Blog.Post posts title:string body:text user_id:references:users

# ================
# AGREGAR A CONTEXT EXISTENTE
# ================

mix phx.gen.context Accounts Profile profiles bio:text user_id:references:users
# Agrega Profile al context Accounts existente

# ================
# TIPOS DE CAMPOS
# ================

# name:string           -> VARCHAR
# body:text             -> TEXT
# age:integer           -> INTEGER
# price:float           -> FLOAT
# price:decimal         -> DECIMAL
# active:boolean        -> BOOLEAN
# birthday:date         -> DATE
# start_time:time       -> TIME
# created_at:datetime   -> TIMESTAMP
# data:map              -> JSONB
# tags:array:string     -> ARRAY
# user_id:references:users -> FOREIGN KEY
""")

# ==========================================
# TESTING CONTEXTS
# ==========================================

IO.puts("\n=== TESTING ===")

IO.puts("""
# test/mi_app/accounts_test.exs

defmodule MiApp.AccountsTest do
  use MiApp.DataCase

  alias MiApp.Accounts

  describe \"users\" do
    alias MiApp.Accounts.User

    @valid_attrs %{name: \"Juan\", email: \"juan@mail.com\"}
    @invalid_attrs %{name: nil, email: nil}

    test \"list_users/0 returns all users\" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test \"get_user!/1 returns the user with given id\" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test \"create_user/1 with valid data creates a user\" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == \"Juan\"
      assert user.email == \"juan@mail.com\"
    end

    test \"create_user/1 with invalid data returns error changeset\" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test \"update_user/2 with valid data updates the user\" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, %{name: \"Pedro\"})
      assert user.name == \"Pedro\"
    end

    test \"delete_user/1 deletes the user\" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    # Helper para crear usuarios de prueba
    defp user_fixture(attrs \\\\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()
      user
    end
  end
end
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
ESTRUCTURA:
  lib/mi_app/
    accounts/           # Context Accounts
      user.ex           # Schema
      accounts.ex       # API publica (CRUD + logica)
    blog/               # Context Blog
      post.ex
      blog.ex

REGLAS:
1. Controllers SOLO llaman al Context
2. Context maneja Ecto y logica de negocio
3. Schema define estructura y changesets
4. Evitar dependencias circulares entre contexts

GENERADORES:
  mix phx.gen.html Context Schema table campo:tipo
  mix phx.gen.live Context Schema table campo:tipo
  mix phx.gen.json Context Schema table campo:tipo
  mix phx.gen.context Context Schema table campo:tipo

BENEFICIOS:
- Codigo organizado
- Facil de testear
- Reutilizable
- Mantenible
""")
