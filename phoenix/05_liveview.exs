# ==========================================
# PHOENIX LIVEVIEW
# ==========================================
#
# LiveView permite crear interfaces reactivas en tiempo real
# SIN escribir JavaScript. El servidor mantiene el estado
# y envia actualizaciones via WebSocket.
#
# Ventajas:
# - UI reactiva sin JS frameworks (React, Vue, etc)
# - El estado vive en el servidor (Elixir)
# - Actualizaciones eficientes (solo diffs del DOM)
# - SEO friendly (renderizado inicial en servidor)

# ==========================================
# LIVEVIEW BASICO
# ==========================================

IO.puts("=== LIVEVIEW BASICO ===")

IO.puts("""
# lib/mi_app_web/live/counter_live.ex

defmodule MiAppWeb.CounterLive do
  use MiAppWeb, :live_view

  # ================
  # MOUNT - inicializacion
  # ================

  def mount(_params, _session, socket) do
    # Inicializar estado con assign
    {:ok, assign(socket, count: 0)}
  end

  # ================
  # RENDER - UI
  # ================

  def render(assigns) do
    ~H\"\"\"
    <div>
      <h1>Contador: <%= @count %></h1>
      <button phx-click=\"increment\">+1</button>
      <button phx-click=\"decrement\">-1</button>
      <button phx-click=\"reset\">Reset</button>
    </div>
    \"\"\"
  end

  # ================
  # HANDLE_EVENT - manejar clicks
  # ================

  def handle_event(\"increment\", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event(\"decrement\", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def handle_event(\"reset\", _params, socket) do
    {:noreply, assign(socket, count: 0)}
  end
end

# ================
# AGREGAR RUTA
# ================

# router.ex
live \"/counter\", CounterLive
""")

# ==========================================
# EVENTOS Y BINDINGS
# ==========================================

IO.puts("\n=== EVENTOS ===")

IO.puts("""
# ================
# EVENTOS DE CLICK
# ================

<button phx-click=\"do_something\">Click</button>

# Con valor
<button phx-click=\"delete\" phx-value-id={@user.id}>Eliminar</button>

def handle_event(\"delete\", %{\"id\" => id}, socket) do
  # id viene del phx-value-id
  {:noreply, socket}
end

# ================
# EVENTOS DE FORMULARIO
# ================

<.form for={@form} phx-submit=\"save\" phx-change=\"validate\">
  <.input field={@form[:name]} label=\"Nombre\" />
  <.button>Guardar</.button>
</.form>

def handle_event(\"validate\", %{\"user\" => params}, socket) do
  changeset = User.changeset(%User{}, params)
  {:noreply, assign(socket, form: to_form(changeset))}
end

def handle_event(\"save\", %{\"user\" => params}, socket) do
  case Accounts.create_user(params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, \"Creado!\")
       |> push_navigate(to: ~p\"/users/\#{user}\")}

    {:error, changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end

# ================
# OTROS EVENTOS
# ================

# Focus/Blur
<input phx-focus=\"input_focused\" phx-blur=\"input_blurred\" />

# Key events
<div phx-window-keydown=\"key_pressed\" phx-key=\"Enter\">

# Debounce (esperar que deje de escribir)
<input phx-change=\"search\" phx-debounce=\"300\" />

# Throttle (maximo una vez cada N ms)
<div phx-click=\"action\" phx-throttle=\"1000\">
""")

# ==========================================
# MANEJO DE ESTADO
# ==========================================

IO.puts("\n=== MANEJO DE ESTADO ===")

IO.puts("""
# ================
# ASSIGNS
# ================

# Asignar valores
socket = assign(socket, name: \"Juan\", age: 30)

# Asignar multiples
socket = assign(socket, %{name: \"Juan\", age: 30})

# Actualizar valor existente
socket = update(socket, :count, &(&1 + 1))

# Leer assigns
socket.assigns.name
socket.assigns[:name]

# En template, usar @
<p>Nombre: <%= @name %></p>

# ================
# ASSIGN_NEW
# ================

# Solo asigna si no existe (para evitar recalcular)
socket = assign_new(socket, :expensive_data, fn ->
  calculate_expensive_data()
end)

# ================
# TEMPORARY ASSIGNS
# ================

# Para listas grandes que no necesitas mantener en memoria
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> assign(:messages, list_messages())
   |> temporary_assigns(:messages, [])}  # se resetea despues de render
end

# En template, usar phx-update=\"append\" o \"prepend\"
<ul id=\"messages\" phx-update=\"append\">
  <%= for msg <- @messages do %>
    <li id={\"msg-\#{msg.id}\"}><%= msg.text %></li>
  <% end %>
</ul>
""")

# ==========================================
# CICLO DE VIDA
# ==========================================

IO.puts("\n=== CICLO DE VIDA ===")

IO.puts("""
# ================
# MOUNT
# ================

def mount(params, session, socket) do
  # params: parametros de la URL (/users/:id -> %{\"id\" => \"1\"})
  # session: datos de sesion
  # socket: conexion LiveView

  # connected?/1 indica si es la conexion WebSocket (no HTTP inicial)
  if connected?(socket) do
    # Solo se ejecuta en la conexion WebSocket
    # Ideal para suscribirse a eventos
    Phoenix.PubSub.subscribe(MiApp.PubSub, \"updates\")
  end

  {:ok, assign(socket, data: load_data())}
end

# ================
# HANDLE_PARAMS
# ================

# Se llama cuando cambian los params de la URL
def handle_params(%{\"id\" => id}, _uri, socket) do
  user = Accounts.get_user!(id)
  {:noreply, assign(socket, user: user)}
end

def handle_params(_params, _uri, socket) do
  {:noreply, socket}
end

# ================
# HANDLE_INFO
# ================

# Recibir mensajes de otros procesos (PubSub, self())
def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, fn msgs -> [message | msgs] end)}
end

def handle_info(:tick, socket) do
  {:noreply, update(socket, :time, fn _ -> DateTime.utc_now() end)}
end

# Programar mensaje periodico
def mount(_params, _session, socket) do
  if connected?(socket) do
    :timer.send_interval(1000, self(), :tick)
  end
  {:ok, assign(socket, time: DateTime.utc_now())}
end
""")

# ==========================================
# NAVEGACION
# ==========================================

IO.puts("\n=== NAVEGACION ===")

IO.puts("""
# ================
# PUSH_NAVIGATE
# ================

# Navegar a otra LiveView (recarga completa del LiveView)
{:noreply, push_navigate(socket, to: ~p\"/users\")}

# Con replace (no agrega a historial)
{:noreply, push_navigate(socket, to: ~p\"/users\", replace: true)}

# ================
# PUSH_PATCH
# ================

# Actualizar URL sin recargar LiveView (solo handle_params)
{:noreply, push_patch(socket, to: ~p\"/users?\#{[page: 2]}\")}

# Util para:
# - Paginacion
# - Filtros
# - Tabs

# ================
# LIVE_PATCH LINK
# ================

# En template
<.link patch={~p\"/users?page=2\"}>Pagina 2</.link>

# ================
# LIVE_NAVIGATE LINK
# ================

<.link navigate={~p\"/other_live\"}>Ir a otra LiveView</.link>

# ================
# REDIRECT EXTERNO
# ================

{:noreply, redirect(socket, to: \"/regular-page\")}
{:noreply, redirect(socket, external: \"https://google.com\")}
""")

# ==========================================
# LIVE COMPONENTS
# ==========================================

IO.puts("\n=== LIVE COMPONENTS ===")

IO.puts("""
# LiveComponents son componentes con estado propio

# ================
# DEFINIR COMPONENT
# ================

defmodule MiAppWeb.UserFormComponent do
  use MiAppWeb, :live_component

  def render(assigns) do
    ~H\"\"\"
    <div>
      <.form for={@form} phx-submit=\"save\" phx-target={@myself}>
        <.input field={@form[:name]} label=\"Nombre\" />
        <.input field={@form[:email]} label=\"Email\" />
        <.button>Guardar</.button>
      </.form>
    </div>
    \"\"\"
  end

  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: to_form(changeset))}
  end

  def handle_event(\"save\", %{\"user\" => params}, socket) do
    case Accounts.update_user(socket.assigns.user, params) do
      {:ok, user} ->
        # Notificar al padre
        send(self(), {:user_updated, user})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end

# ================
# USAR COMPONENT
# ================

# phx-target={@myself} envia eventos al componente, no al padre

<.live_component
  module={MiAppWeb.UserFormComponent}
  id={@user.id}
  user={@user}
/>

# id es REQUERIDO para componentes stateful

# ================
# EN EL PADRE
# ================

def handle_info({:user_updated, user}, socket) do
  {:noreply,
   socket
   |> put_flash(:info, \"Usuario actualizado\")
   |> assign(:user, user)}
end
""")

# ==========================================
# PUBSUB - TIEMPO REAL
# ==========================================

IO.puts("\n=== PUBSUB ===")

IO.puts("""
# PubSub permite comunicacion entre procesos/LiveViews

# ================
# SUSCRIBIRSE
# ================

def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MiApp.PubSub, \"chat:lobby\")
  end
  {:ok, assign(socket, messages: [])}
end

# ================
# PUBLICAR
# ================

def handle_event(\"send_message\", %{\"text\" => text}, socket) do
  message = %{text: text, user: socket.assigns.current_user}

  # Broadcast a todos los suscriptos
  Phoenix.PubSub.broadcast(MiApp.PubSub, \"chat:lobby\", {:new_message, message})

  {:noreply, socket}
end

# ================
# RECIBIR
# ================

def handle_info({:new_message, message}, socket) do
  {:noreply, update(socket, :messages, fn msgs -> msgs ++ [message] end)}
end

# ================
# CASO COMUN: CRUD
# ================

# Cuando creas/actualizas/eliminas, notificar a todas las LiveViews

def create_user(attrs) do
  case Repo.insert(changeset) do
    {:ok, user} ->
      Phoenix.PubSub.broadcast(MiApp.PubSub, \"users\", {:user_created, user})
      {:ok, user}
    error -> error
  end
end

# En LiveView que lista usuarios:
def mount(_params, _session, socket) do
  if connected?(socket), do: Phoenix.PubSub.subscribe(MiApp.PubSub, \"users\")
  {:ok, assign(socket, users: list_users())}
end

def handle_info({:user_created, user}, socket) do
  {:noreply, update(socket, :users, fn users -> [user | users] end)}
end
""")

# ==========================================
# UPLOADS
# ==========================================

IO.puts("\n=== UPLOADS ===")

IO.puts("""
# LiveView soporta uploads directos

def mount(_params, _session, socket) do
  {:ok,
   socket
   |> allow_upload(:avatar,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 5_000_000)}
end

def render(assigns) do
  ~H\"\"\"
  <form phx-submit=\"save\" phx-change=\"validate\">
    <.live_file_input upload={@uploads.avatar} />

    <%!-- Preview --%>
    <%= for entry <- @uploads.avatar.entries do %>
      <.live_img_preview entry={entry} />
      <button phx-click=\"cancel-upload\" phx-value-ref={entry.ref}>X</button>
    <% end %>

    <button type=\"submit\">Upload</button>
  </form>
  \"\"\"
end

def handle_event(\"validate\", _params, socket) do
  {:noreply, socket}
end

def handle_event(\"save\", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
      dest = Path.join(\"priv/static/uploads\", entry.client_name)
      File.cp!(path, dest)
      {:ok, \"/uploads/\" <> entry.client_name}
    end)

  {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
end

def handle_event(\"cancel-upload\", %{\"ref\" => ref}, socket) do
  {:noreply, cancel_upload(socket, :avatar, ref)}
end
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
ESTRUCTURA LIVEVIEW:
  mount/3       - inicializacion
  render/1      - UI (HEEx)
  handle_event  - eventos del cliente
  handle_info   - mensajes de otros procesos
  handle_params - cambios de URL

EVENTOS:
  phx-click, phx-submit, phx-change
  phx-blur, phx-focus
  phx-debounce, phx-throttle

ESTADO:
  assign(socket, key: value)
  update(socket, :key, fn)
  @key en template

NAVEGACION:
  push_navigate - ir a otra LiveView
  push_patch    - actualizar URL (misma LiveView)

TIEMPO REAL:
  Phoenix.PubSub.subscribe
  Phoenix.PubSub.broadcast

SIGUIENTE: ver 06_plugs.exs
""")
