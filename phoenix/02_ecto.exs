# ==========================================
# ECTO - ACCESO A BASE DE DATOS
# ==========================================
#
# Ecto es la libreria de base de datos de Elixir.
# NO es un ORM tradicional - es mas explicito y funcional.
#
# Componentes principales:
# - Repo: interfaz con la base de datos
# - Schema: define estructura de datos
# - Changeset: validacion y transformacion
# - Query: consultas composables

# ==========================================
# REPO - CONEXION A LA BASE DE DATOS
# ==========================================

IO.puts("=== REPO ===")

IO.puts("""
# lib/mi_app/repo.ex

defmodule MiApp.Repo do
  use Ecto.Repo,
    otp_app: :mi_app,
    adapter: Ecto.Adapters.Postgres
end

# El Repo es el punto de entrada a la DB
# Todas las operaciones pasan por el:
#
# MiApp.Repo.all(User)         # SELECT * FROM users
# MiApp.Repo.get(User, 1)      # SELECT * FROM users WHERE id = 1
# MiApp.Repo.insert(changeset) # INSERT INTO users ...
# MiApp.Repo.update(changeset) # UPDATE users SET ...
# MiApp.Repo.delete(user)      # DELETE FROM users WHERE ...
""")

# ==========================================
# MIGRATIONS - DEFINIR ESTRUCTURA
# ==========================================

IO.puts("\n=== MIGRATIONS ===")

IO.puts("""
# Crear migracion:
# mix ecto.gen.migration create_users

# priv/repo/migrations/20240101120000_create_users.exs

defmodule MiApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :age, :integer
      add :bio, :text
      add :is_admin, :boolean, default: false
      add :balance, :decimal, precision: 10, scale: 2

      timestamps()  # inserted_at, updated_at
    end

    # Indices
    create unique_index(:users, [:email])
    create index(:users, [:name])
  end
end

# ----------------------------------------
# Migracion con relaciones

defmodule MiApp.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string, null: false
      add :body, :text
      add :published, :boolean, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:posts, [:user_id])
  end
end

# ----------------------------------------
# Modificar tabla existente

defmodule MiApp.Repo.Migrations.AddAvatarToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar_url, :string
      remove :bio  # eliminar columna
    end
  end
end

# COMANDOS:
# mix ecto.migrate          # aplicar migraciones
# mix ecto.rollback         # revertir ultima
# mix ecto.rollback -n 3    # revertir 3 migraciones
""")

# ==========================================
# SCHEMA - DEFINIR ESTRUCTURA EN ELIXIR
# ==========================================

IO.puts("\n=== SCHEMA ===")

IO.puts("""
# lib/mi_app/accounts/user.ex

defmodule MiApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema \"users\" do
    field :name, :string
    field :email, :string
    field :age, :integer
    field :is_admin, :boolean, default: false
    field :balance, :decimal

    # Relaciones
    has_many :posts, MiApp.Blog.Post
    has_one :profile, MiApp.Accounts.Profile
    belongs_to :company, MiApp.Companies.Company

    # Campo virtual (no va a DB)
    field :password, :string, virtual: true

    timestamps()
  end

  # Changeset para crear usuario
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :age, :is_admin])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:name, min: 2, max: 100)
    |> validate_number(:age, greater_than: 0, less_than: 150)
    |> unique_constraint(:email)
  end
end

# TIPOS COMUNES:
# :string       - VARCHAR
# :text         - TEXT (largo)
# :integer      - INTEGER
# :float        - FLOAT
# :decimal      - DECIMAL (precision)
# :boolean      - BOOLEAN
# :date         - DATE
# :time         - TIME
# :naive_datetime - DATETIME sin timezone
# :utc_datetime - DATETIME con timezone
# :binary       - BLOB
# :map          - JSONB
# {:array, :string} - ARRAY de strings
""")

# ==========================================
# CHANGESET - VALIDACION
# ==========================================

IO.puts("\n=== CHANGESET ===")

IO.puts("""
# El Changeset es central en Ecto
# Representa un CAMBIO propuesto a los datos
# Contiene: datos originales, cambios, validaciones, errores

defmodule MiApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema \"users\" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :age, :integer
    timestamps()
  end

  # Changeset para registro
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :age])
    |> validate_required([:name, :email, :password])
    |> validate_email()
    |> validate_password()
    |> hash_password()
  end

  # Changeset para actualizar perfil (sin password)
  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :age])
    |> validate_required([:name])
    |> validate_length(:name, min: 2)
  end

  # Validaciones personalizadas
  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^@]+@[^@]+$/, message: \"email invalido\")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 8, message: \"minimo 8 caracteres\")
    |> validate_format(:password, ~r/[A-Z]/, message: \"debe tener mayuscula\")
    |> validate_format(:password, ~r/[0-9]/, message: \"debe tener numero\")
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        changeset
        |> put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
        |> delete_change(:password)
    end
  end
end

# VALIDACIONES DISPONIBLES:
# validate_required([:campo1, :campo2])
# validate_length(:campo, min: 2, max: 100)
# validate_format(:campo, ~r/regex/)
# validate_number(:campo, greater_than: 0)
# validate_inclusion(:campo, [\"a\", \"b\", \"c\"])
# validate_exclusion(:campo, [\"malo\"])
# validate_acceptance(:terminos)  # checkbox
# validate_confirmation(:password)  # password_confirmation
# unique_constraint(:email)
# foreign_key_constraint(:user_id)
# check_constraint(:age, name: :age_must_be_positive)

# FUNCIONES UTILES:
# cast(struct, params, campos)     - filtrar y convertir params
# put_change(changeset, :campo, valor)  - agregar cambio
# get_change(changeset, :campo)    - obtener cambio
# get_field(changeset, :campo)     - obtener valor (original o cambio)
# delete_change(changeset, :campo) - quitar cambio
# add_error(changeset, :campo, \"mensaje\")  - agregar error manual
""")

# ==========================================
# QUERIES - CONSULTAS
# ==========================================

IO.puts("\n=== QUERIES ===")

IO.puts("""
import Ecto.Query
alias MiApp.Repo
alias MiApp.Accounts.User

# ================
# QUERIES BASICAS
# ================

# Todos los registros
users = Repo.all(User)

# Por ID
user = Repo.get(User, 1)       # nil si no existe
user = Repo.get!(User, 1)      # raise si no existe

# Por campo
user = Repo.get_by(User, email: \"juan@mail.com\")
user = Repo.get_by!(User, email: \"juan@mail.com\")

# Primero/Ultimo
first = Repo.one(from u in User, order_by: u.id, limit: 1)

# Contar
count = Repo.aggregate(User, :count)

# ================
# QUERY DSL
# ================

# Select con where
query = from u in User,
        where: u.age > 18,
        select: u

adults = Repo.all(query)

# Select campos especificos
query = from u in User,
        where: u.is_admin == true,
        select: {u.name, u.email}

admins = Repo.all(query)  # [{\"Juan\", \"juan@...\"}, ...]

# Select como map
query = from u in User,
        select: %{nombre: u.name, correo: u.email}

# Order by
query = from u in User,
        order_by: [desc: u.inserted_at],
        limit: 10

# Group by
query = from u in User,
        group_by: u.is_admin,
        select: {u.is_admin, count(u.id)}

# Join
query = from u in User,
        join: p in assoc(u, :posts),
        where: p.published == true,
        select: {u.name, p.title}

# Preload (cargar asociaciones)
users = Repo.all(from u in User, preload: [:posts, :profile])

# Preload despues
users = Repo.all(User) |> Repo.preload(:posts)

# ================
# QUERIES DINAMICAS
# ================

# Composicion de queries
def list_users(filters) do
  User
  |> maybe_filter_by_admin(filters[:admin])
  |> maybe_filter_by_age(filters[:min_age])
  |> order_by([u], desc: u.inserted_at)
  |> Repo.all()
end

defp maybe_filter_by_admin(query, nil), do: query
defp maybe_filter_by_admin(query, is_admin) do
  where(query, [u], u.is_admin == ^is_admin)
end

defp maybe_filter_by_age(query, nil), do: query
defp maybe_filter_by_age(query, min_age) do
  where(query, [u], u.age >= ^min_age)
end

# Usando dynamic
def search_users(term) do
  search = \"%\#{term}%\"

  conditions = dynamic([u], ilike(u.name, ^search) or ilike(u.email, ^search))

  from(u in User, where: ^conditions)
  |> Repo.all()
end

# ================
# OPERACIONES
# ================

# Insert
{:ok, user} = Repo.insert(%User{name: \"Juan\", email: \"juan@mail.com\"})
# o con changeset (recomendado)
{:ok, user} = %User{} |> User.changeset(params) |> Repo.insert()

# Update
{:ok, user} = user |> User.changeset(%{name: \"Nuevo\"}) |> Repo.update()

# Delete
{:ok, _} = Repo.delete(user)

# Insert or Update
Repo.insert(changeset, on_conflict: :replace_all, conflict_target: :email)

# Update all (sin cargar)
Repo.update_all(User, set: [is_admin: false])
Repo.update_all(from(u in User, where: u.age < 18), set: [is_admin: false])

# Delete all
Repo.delete_all(from u in User, where: u.age < 0)
""")

# ==========================================
# RELACIONES
# ==========================================

IO.puts("\n=== RELACIONES ===")

IO.puts("""
# ================
# BELONGS_TO / HAS_MANY
# ================

# Post pertenece a User
defmodule MiApp.Blog.Post do
  schema \"posts\" do
    field :title, :string
    belongs_to :user, MiApp.Accounts.User
    timestamps()
  end
end

# User tiene muchos Posts
defmodule MiApp.Accounts.User do
  schema \"users\" do
    field :name, :string
    has_many :posts, MiApp.Blog.Post
    timestamps()
  end
end

# ================
# HAS_ONE
# ================

defmodule MiApp.Accounts.User do
  schema \"users\" do
    has_one :profile, MiApp.Accounts.Profile
  end
end

defmodule MiApp.Accounts.Profile do
  schema \"profiles\" do
    field :bio, :string
    belongs_to :user, MiApp.Accounts.User
  end
end

# ================
# MANY_TO_MANY
# ================

# Con tabla intermedia explicita
defmodule MiApp.Blog.Post do
  schema \"posts\" do
    many_to_many :tags, MiApp.Blog.Tag, join_through: \"posts_tags\"
  end
end

defmodule MiApp.Blog.Tag do
  schema \"tags\" do
    many_to_many :posts, MiApp.Blog.Post, join_through: \"posts_tags\"
  end
end

# Migracion para tabla intermedia
create table(:posts_tags, primary_key: false) do
  add :post_id, references(:posts, on_delete: :delete_all)
  add :tag_id, references(:tags, on_delete: :delete_all)
end

create unique_index(:posts_tags, [:post_id, :tag_id])

# ================
# PRELOAD Y JOINS
# ================

# Preload - carga adicional (N+1 queries optimizado)
users = Repo.all(User) |> Repo.preload(:posts)

# Preload en query
users = Repo.all(from u in User, preload: [:posts, :profile])

# Preload con query personalizada
published_posts = from p in Post, where: p.published == true
users = Repo.all(from u in User, preload: [posts: ^published_posts])

# Join + preload (1 query)
users = Repo.all(
  from u in User,
  join: p in assoc(u, :posts),
  where: p.published == true,
  preload: [posts: p]
)
""")

# ==========================================
# TRANSACCIONES
# ==========================================

IO.puts("\n=== TRANSACCIONES ===")

IO.puts("""
# Transaccion simple
Repo.transaction(fn ->
  user = Repo.insert!(%User{name: \"Juan\"})
  Repo.insert!(%Post{title: \"Hola\", user_id: user.id})
  user
end)

# Rollback explicito
Repo.transaction(fn ->
  case Repo.insert(changeset) do
    {:ok, user} -> user
    {:error, changeset} -> Repo.rollback(changeset)
  end
end)

# Ecto.Multi - transacciones complejas
alias Ecto.Multi

Multi.new()
|> Multi.insert(:user, User.changeset(%User{}, user_params))
|> Multi.insert(:profile, fn %{user: user} ->
     Profile.changeset(%Profile{user_id: user.id}, profile_params)
   end)
|> Multi.update(:user_with_profile, fn %{user: user, profile: profile} ->
     User.changeset(user, %{has_profile: true})
   end)
|> Repo.transaction()

# Resultado de Multi
case Repo.transaction(multi) do
  {:ok, %{user: user, profile: profile}} ->
    # exito
  {:error, :user, changeset, _changes} ->
    # fallo en paso :user
  {:error, :profile, changeset, _changes} ->
    # fallo en paso :profile
end
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
COMPONENTES ECTO:
  Repo      - interfaz con DB
  Schema    - estructura de datos
  Changeset - validacion/transformacion
  Query     - consultas composables
  Migration - cambios de esquema

FLUJO TIPICO:
  1. params llegan del controller
  2. crear changeset con validacion
  3. si valido, Repo.insert/update
  4. manejar {:ok, struct} o {:error, changeset}

COMANDOS:
  mix ecto.gen.migration nombre
  mix ecto.migrate
  mix ecto.rollback

SIGUIENTE: ver 03_router_controllers.exs
""")
