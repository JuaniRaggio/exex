# ==========================================
# GENSERVER - SERVIDOR GENERICO
# ==========================================
#
# GenServer es una abstraccion sobre el patron de servidor que
# vimos en archivos anteriores. Provee:
# - Estructura estandar para servidores
# - Llamadas sincronas (call) y asincronas (cast)
# - Manejo de estado integrado
# - Integracion con supervisores
#
# En lugar de escribir loops y receives manualmente,
# implementamos "callbacks" que GenServer llama por nosotros.

# ==========================================
# GENSERVER BASICO
# ==========================================

IO.puts("=== GENSERVER BASICO ===")

defmodule ContadorGen do
  use GenServer

  # ================
  # API PUBLICA (cliente)
  # ================

  def start_link(valor_inicial \\ 0) do
    GenServer.start_link(__MODULE__, valor_inicial)
  end

  def incrementar(pid) do
    GenServer.cast(pid, :incrementar)
  end

  def valor(pid) do
    GenServer.call(pid, :valor)
  end

  # ================
  # CALLBACKS (servidor)
  # ================

  @impl true
  def init(valor_inicial) do
    # init recibe el segundo argumento de start_link
    # Debe retornar {:ok, estado_inicial}
    {:ok, valor_inicial}
  end

  @impl true
  def handle_cast(:incrementar, estado) do
    # cast es ASINCRONO (fire and forget)
    # Retorna {:noreply, nuevo_estado}
    {:noreply, estado + 1}
  end

  @impl true
  def handle_call(:valor, _from, estado) do
    # call es SINCRONO (espera respuesta)
    # Retorna {:reply, respuesta, nuevo_estado}
    {:reply, estado, estado}
  end
end

# Uso
{:ok, pid} = ContadorGen.start_link(10)
IO.inspect(ContadorGen.valor(pid), label: "Valor inicial")

ContadorGen.incrementar(pid)
ContadorGen.incrementar(pid)
ContadorGen.incrementar(pid)

IO.inspect(ContadorGen.valor(pid), label: "Despues de 3 incrementos")

# Detener el servidor
GenServer.stop(pid)

# ==========================================
# CALL vs CAST
# ==========================================

IO.puts("\n=== CALL vs CAST ===")

IO.puts("""
CALL (sincrono):
- GenServer.call(pid, mensaje)
- El cliente ESPERA la respuesta
- Usa handle_call/3
- Timeout por defecto: 5000ms
- Usar para: obtener datos, operaciones que necesitan confirmacion

CAST (asincrono):
- GenServer.cast(pid, mensaje)
- El cliente NO espera
- Usa handle_cast/2
- No hay respuesta
- Usar para: comandos, notificaciones, fire-and-forget
""")

# ==========================================
# GENSERVER CON ESTADO COMPLEJO
# ==========================================

IO.puts("\n=== ESTADO COMPLEJO ===")

defmodule Carrito do
  use GenServer

  # API
  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def agregar(pid, item), do: GenServer.cast(pid, {:agregar, item})
  def remover(pid, item), do: GenServer.cast(pid, {:remover, item})
  def items(pid), do: GenServer.call(pid, :items)
  def total(pid), do: GenServer.call(pid, :total)
  def vaciar(pid), do: GenServer.cast(pid, :vaciar)

  # Callbacks
  @impl true
  def init(_), do: {:ok, []}

  @impl true
  def handle_cast({:agregar, item}, items) do
    {:noreply, [item | items]}
  end

  @impl true
  def handle_cast({:remover, item}, items) do
    {:noreply, List.delete(items, item)}
  end

  @impl true
  def handle_cast(:vaciar, _items) do
    {:noreply, []}
  end

  @impl true
  def handle_call(:items, _from, items) do
    {:reply, items, items}
  end

  @impl true
  def handle_call(:total, _from, items) do
    total = items |> Enum.map(& &1.precio) |> Enum.sum()
    {:reply, total, items}
  end
end

{:ok, carrito} = Carrito.start_link()

Carrito.agregar(carrito, %{nombre: "Manzana", precio: 100})
Carrito.agregar(carrito, %{nombre: "Pan", precio: 50})
Carrito.agregar(carrito, %{nombre: "Leche", precio: 80})

IO.inspect(Carrito.items(carrito), label: "Items")
IO.inspect(Carrito.total(carrito), label: "Total")

GenServer.stop(carrito)

# ==========================================
# PROCESOS CON NOMBRE
# ==========================================

IO.puts("\n=== PROCESOS CON NOMBRE ===")

defmodule Cache do
  use GenServer

  # Iniciar con nombre
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # API usa el nombre del modulo, no PID
  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def all() do
    GenServer.call(__MODULE__, :all)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end
end

Cache.start_link()

Cache.put(:usuario, "Juan")
Cache.put(:rol, "admin")

IO.inspect(Cache.get(:usuario), label: "Usuario")
IO.inspect(Cache.all(), label: "Todo el cache")

GenServer.stop(Cache)

# ==========================================
# HANDLE_INFO - MENSAJES NO ESTRUCTURADOS
# ==========================================

IO.puts("\n=== HANDLE_INFO ===")

defmodule ConTimer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, 0)
  end

  def valor(pid), do: GenServer.call(pid, :valor)

  @impl true
  def init(state) do
    # Programar mensaje periodico
    :timer.send_interval(100, :tick)
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    # handle_info maneja mensajes que NO son call/cast
    # Ej: mensajes de timer, mensajes manuales con send()
    {:noreply, state + 1}
  end

  @impl true
  def handle_call(:valor, _from, state) do
    {:reply, state, state}
  end
end

{:ok, timer_pid} = ConTimer.start_link()
Process.sleep(350)  # Esperar algunos ticks
IO.inspect(ConTimer.valor(timer_pid), label: "Ticks contados")
GenServer.stop(timer_pid)

# ==========================================
# TIMEOUT EN CALL
# ==========================================

IO.puts("\n=== TIMEOUT ===")

defmodule Lento do
  use GenServer

  def start_link(), do: GenServer.start_link(__MODULE__, nil)

  def operacion_lenta(pid) do
    # Timeout personalizado de 500ms
    GenServer.call(pid, :lento, 500)
  end

  @impl true
  def init(_), do: {:ok, nil}

  @impl true
  def handle_call(:lento, _from, state) do
    Process.sleep(1000)  # Simular operacion lenta
    {:reply, :ok, state}
  end
end

{:ok, lento_pid} = Lento.start_link()

# Esto va a dar timeout porque la operacion tarda 1000ms
# y el timeout es 500ms
try do
  Lento.operacion_lenta(lento_pid)
catch
  :exit, {:timeout, _} ->
    IO.puts("Timeout! La operacion tardo demasiado")
end

GenServer.stop(lento_pid)

# ==========================================
# TERMINATE - LIMPIEZA AL MORIR
# ==========================================

IO.puts("\n=== TERMINATE ===")

defmodule ConLimpieza do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    IO.puts("Servidor iniciado")
    {:ok, nil}
  end

  @impl true
  def terminate(razon, _state) do
    # Se llama cuando el servidor se detiene
    IO.puts("Servidor terminando por: #{inspect(razon)}")
    :ok
  end
end

{:ok, limpieza_pid} = ConLimpieza.start_link()
GenServer.stop(limpieza_pid, :normal)
Process.sleep(50)

# ==========================================
# RETORNOS DE CALLBACKS
# ==========================================

IO.puts("\n=== RETORNOS DE CALLBACKS ===")

IO.puts("""
init/1:
  {:ok, estado}                 - OK, estado inicial
  {:ok, estado, timeout}        - OK, con timeout para handle_info(:timeout)
  {:ok, estado, :hibernate}     - OK, hibernar para ahorrar memoria
  :ignore                       - No iniciar servidor
  {:stop, razon}                - No iniciar, error

handle_call/3:
  {:reply, respuesta, estado}   - Responder y continuar
  {:reply, respuesta, estado, timeout}
  {:noreply, estado}            - No responder aun (responder async)
  {:stop, razon, respuesta, estado}  - Responder y terminar
  {:stop, razon, estado}        - Terminar sin responder

handle_cast/2:
  {:noreply, estado}            - Continuar
  {:noreply, estado, timeout}
  {:stop, razon, estado}        - Terminar

handle_info/2:
  (igual que handle_cast)
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
GENSERVER ES:
- Abstraccion sobre proceso + receive + estado
- Patron estandar para servidores en Elixir
- Integrado con supervision trees

ESTRUCTURA:
1. use GenServer
2. API publica: funciones que llaman GenServer.call/cast
3. Callbacks: init, handle_call, handle_cast, handle_info, terminate

COMUNICACION:
- call: sincrono, espera respuesta
- cast: asincrono, fire-and-forget
- handle_info: mensajes externos (timers, etc)

SIGUIENTE: ver 05_agents.exs y 06_tasks.exs
para abstracciones mas simples
""")
