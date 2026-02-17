# ==========================================
# TEMPLATES HEEx EN PHOENIX
# ==========================================
#
# HEEx = HTML + Embedded Elixir
# Es el sistema de templates de Phoenix.
# Combina HTML con expresiones Elixir.

# ==========================================
# SINTAXIS BASICA
# ==========================================

IO.puts("=== SINTAXIS HEEx ===")

IO.puts("""
# ================
# INTERPOLACION
# ================

# Mostrar valor (escaped automaticamente)
<h1><%= @user.name %></h1>
<p>Email: <%= @email %></p>

# Sin escape (CUIDADO - solo contenido seguro)
<%= raw(@html_content) %>

# ================
# CONDICIONALES
# ================

# if/else
<%= if @logged_in do %>
  <p>Bienvenido, <%= @user.name %></p>
<% else %>
  <a href=\"/login\">Iniciar sesion</a>
<% end %>

# unless
<%= unless @error do %>
  <p>Todo bien</p>
<% end %>

# case
<%= case @status do %>
  <% :ok -> %><span class=\"green\">OK</span>
  <% :error -> %><span class=\"red\">Error</span>
  <% _ -> %><span>Desconocido</span>
<% end %>

# ================
# LOOPS
# ================

# for
<ul>
  <%= for user <- @users do %>
    <li><%= user.name %></li>
  <% end %>
</ul>

# for con indice
<%= for {user, index} <- Enum.with_index(@users) do %>
  <tr class={if rem(index, 2) == 0, do: \"even\", else: \"odd\"}>
    <td><%= user.name %></td>
  </tr>
<% end %>

# ================
# ATRIBUTOS DINAMICOS
# ================

# Clase condicional
<div class={if @active, do: \"active\", else: \"\"}>

# Multiples clases
<div class={[\"base\", @active && \"active\", @error && \"error\"]}>

# Atributos condicionales
<button disabled={@loading}>Submit</button>

# Spread de atributos
<input {@input_attrs} />
""")

# ==========================================
# COMPONENTES
# ==========================================

IO.puts("\n=== COMPONENTES ===")

IO.puts("""
# En Phoenix 1.7+, los componentes son funciones
# que retornan HEEx

# ================
# DEFINIR COMPONENTE
# ================

# lib/mi_app_web/components/core_components.ex

defmodule MiAppWeb.CoreComponents do
  use Phoenix.Component

  # Componente simple
  def button(assigns) do
    ~H\"\"\"
    <button class=\"btn btn-primary\">
      <%= render_slot(@inner_block) %>
    </button>
    \"\"\"
  end

  # Con atributos
  attr :type, :string, default: \"button\"
  attr :class, :string, default: \"\"
  attr :rest, :global

  def button(assigns) do
    ~H\"\"\"
    <button type={@type} class={[\"btn\", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </button>
    \"\"\"
  end

  # Componente con slots
  slot :icon
  slot :inner_block, required: true

  def card(assigns) do
    ~H\"\"\"
    <div class=\"card\">
      <div :if={@icon != []} class=\"card-icon\">
        <%= render_slot(@icon) %>
      </div>
      <div class=\"card-body\">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    \"\"\"
  end
end

# ================
# USAR COMPONENTES
# ================

# En template:

<.button>Click me</.button>

<.button type=\"submit\" class=\"large\">
  Enviar
</.button>

<.card>
  <:icon><img src=\"/icon.png\" /></:icon>
  Contenido de la card
</.card>

# ================
# ATRIBUTOS COMUNES
# ================

# attr define atributos del componente
attr :name, :string, required: true
attr :age, :integer, default: 0
attr :class, :string, default: nil
attr :rest, :global  # captura todos los demas

# slot define slots para contenido
slot :inner_block, required: true
slot :header
slot :footer, doc: \"Pie de pagina\"
""")

# ==========================================
# FORMULARIOS
# ==========================================

IO.puts("\n=== FORMULARIOS ===")

IO.puts("""
# ================
# FORM BASICO
# ================

<.form for={@changeset} action={~p\"/users\"}>
  <.input field={@form[:name]} label=\"Nombre\" />
  <.input field={@form[:email]} type=\"email\" label=\"Email\" />
  <.input field={@form[:age]} type=\"number\" label=\"Edad\" />

  <.button>Crear usuario</.button>
</.form>

# ================
# TIPOS DE INPUT
# ================

<.input type=\"text\" />      # texto
<.input type=\"email\" />     # email
<.input type=\"password\" />  # password
<.input type=\"number\" />    # numero
<.input type=\"textarea\" />  # area de texto
<.input type=\"select\" options={[{\"Uno\", 1}, {\"Dos\", 2}]} />
<.input type=\"checkbox\" />  # checkbox
<.input type=\"hidden\" />    # oculto

# ================
# FORM PARA EDIT
# ================

<.form for={@changeset} action={~p\"/users/\#{@user}\"} method=\"put\">
  <.input field={@form[:name]} label=\"Nombre\" />
  <.input field={@form[:email]} label=\"Email\" />
  <.button>Actualizar</.button>
</.form>

# ================
# MOSTRAR ERRORES
# ================

# El componente .input muestra errores automaticamente
# pero puedes personalizarlo:

<.error :for={msg <- @form[:email].errors}>
  <%= msg %>
</.error>

# ================
# FORM CON ASOCIACIONES
# ================

<.form for={@changeset} action={~p\"/posts\"}>
  <.input field={@form[:title]} label=\"Titulo\" />

  <%!-- Select de relacion --%>
  <.input
    field={@form[:user_id]}
    type=\"select\"
    label=\"Autor\"
    options={Enum.map(@users, &{&1.name, &1.id})}
  />

  <.button>Crear</.button>
</.form>
""")

# ==========================================
# LAYOUTS
# ==========================================

IO.puts("\n=== LAYOUTS ===")

IO.puts("""
# ================
# ROOT LAYOUT
# ================

# lib/mi_app_web/components/layouts/root.html.heex

<!DOCTYPE html>
<html lang=\"es\">
  <head>
    <meta charset=\"utf-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <title><%= assigns[:page_title] || \"Mi App\" %></title>
    <link rel=\"stylesheet\" href={~p\"/assets/app.css\"} />
    <script defer src={~p\"/assets/app.js\"}></script>
  </head>
  <body>
    <%= @inner_content %>
  </body>
</html>

# ================
# APP LAYOUT
# ================

# lib/mi_app_web/components/layouts/app.html.heex

<header>
  <nav>
    <a href={~p\"/\"}>Inicio</a>
    <a href={~p\"/users\"}>Usuarios</a>
  </nav>
</header>

<main class=\"container\">
  <.flash_group flash={@flash} />
  <%= @inner_content %>
</main>

<footer>
  <p>Mi App 2024</p>
</footer>

# ================
# CAMBIAR LAYOUT
# ================

# En el controller:
def index(conn, _params) do
  conn
  |> put_layout(html: :admin)  # usa admin.html.heex
  |> render(:index)
end

# Sin layout:
def raw_page(conn, _params) do
  conn
  |> put_layout(false)
  |> render(:raw)
end
""")

# ==========================================
# HELPERS Y FUNCIONES
# ==========================================

IO.puts("\n=== HELPERS ===")

IO.puts("""
# ================
# LINKS
# ================

<a href={~p\"/users\"}>Ver usuarios</a>
<a href={~p\"/users/\#{@user}\"}>Ver <%= @user.name %></a>

# Link con metodo DELETE
<.link href={~p\"/users/\#{@user}\"} method=\"delete\" data-confirm=\"Seguro?\">
  Eliminar
</.link>

# ================
# IMAGENES Y ASSETS
# ================

<img src={~p\"/images/logo.png\"} alt=\"Logo\" />
<link rel=\"stylesheet\" href={~p\"/assets/app.css\"} />

# ================
# FECHAS
# ================

<%= Calendar.strftime(@user.inserted_at, \"%d/%m/%Y %H:%M\") %>

# ================
# NUMEROS
# ================

<%= Number.Currency.number_to_currency(@price) %>

# ================
# FUNCIONES PROPIAS
# ================

# Definir en un modulo de helpers
defmodule MiAppWeb.Helpers do
  def format_date(date) do
    Calendar.strftime(date, \"%d/%m/%Y\")
  end

  def truncate(text, length \\\\ 50) do
    if String.length(text) > length do
      String.slice(text, 0, length) <> \"...\"
    else
      text
    end
  end
end

# Importar en mi_app_web.ex para usar en todos los templates
def html_helpers do
  quote do
    import MiAppWeb.Helpers
  end
end
""")

# ==========================================
# PARTIALS Y REUTILIZACION
# ==========================================

IO.puts("\n=== PARTIALS ===")

IO.puts("""
# En Phoenix 1.7+ se usan componentes en lugar de partials

# ================
# COMPONENTE REUTILIZABLE
# ================

# components/user_card.ex
defmodule MiAppWeb.Components.UserCard do
  use Phoenix.Component

  attr :user, :map, required: true

  def user_card(assigns) do
    ~H\"\"\"
    <div class=\"user-card\">
      <h3><%= @user.name %></h3>
      <p><%= @user.email %></p>
    </div>
    \"\"\"
  end
end

# Usar en template:
<.user_card user={@user} />

# ================
# LISTA DE COMPONENTES
# ================

<%= for user <- @users do %>
  <.user_card user={user} />
<% end %>

# ================
# COMPONENTE CON SLOT
# ================

attr :title, :string, required: true
slot :actions
slot :inner_block, required: true

def section(assigns) do
  ~H\"\"\"
  <section class=\"section\">
    <header>
      <h2><%= @title %></h2>
      <div :if={@actions != []} class=\"actions\">
        <%= render_slot(@actions) %>
      </div>
    </header>
    <div class=\"content\">
      <%= render_slot(@inner_block) %>
    </div>
  </section>
  \"\"\"
end

# Uso:
<.section title=\"Usuarios\">
  <:actions>
    <.link href={~p\"/users/new\"}>Nuevo</.link>
  </:actions>

  <ul>
    <%= for user <- @users do %>
      <li><%= user.name %></li>
    <% end %>
  </ul>
</.section>
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
SINTAXIS HEEx:
  <%= expr %>     - output escaped
  <% code %>      - code sin output
  @variable       - assigns
  ~p\"/path\"      - path helper

COMPONENTES:
  <.button>text</.button>
  attr :name, :type, options
  slot :name

FORMULARIOS:
  <.form for={@changeset}>
  <.input field={@form[:name]} />
  <.button>Submit</.button>

LAYOUTS:
  root.html.heex  - HTML base
  app.html.heex   - layout de app

SIGUIENTE: ver 05_liveview.exs
""")
