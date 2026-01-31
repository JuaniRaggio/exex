# ==========================================
# AGENTS - ESTADO SIMPLE
# ==========================================
#
# Agent es una abstraccion sobre GenServer para casos donde
# SOLO necesitas mantener estado. Es mucho mas simple.
#
# Perfecto para:
# - Contadores
# - Caches simples
# - Estado compartido basico
#
# Si necesitas logica compleja, usa GenServer directamente.

# ==========================================
# AGENT BASICO
# ==========================================

IO.puts("=== AGENT BASICO ===")

# Iniciar agent con valor inicial
{:ok, agent} = Agent.start_link(fn -> 0 end)
IO.inspect(agent, label: "PID del agent")

# get - obtener el estado
valor = Agent.get(agent, fn state -> state end)
IO.inspect(valor, label: "Valor inicial")

# update - actualizar estado
Agent.update(agent, fn state -> state + 1 end)
Agent.update(agent, fn state -> state + 1 end)
Agent.update(agent, fn state -> state + 1 end)

IO.inspect(Agent.get(agent, & &1), label: "Despues de incrementos")

# get_and_update - obtener y actualizar atomicamente
{viejo, _nuevo} = Agent.get_and_update(agent, fn state ->
  {state, state * 2}  # {valor_retornado, nuevo_estado}
end)
IO.inspect(viejo, label: "Valor antes de duplicar")
IO.inspect(Agent.get(agent, & &1), label: "Valor despues de duplicar")

Agent.stop(agent)

# ==========================================
# AGENT CON NOMBRE
# ==========================================

IO.puts("\n=== AGENT CON NOMBRE ===")

# Usar nombre para no tener que pasar PID
Agent.start_link(fn -> [] end, name: :mi_lista)

Agent.update(:mi_lista, fn lista -> ["a" | lista] end)
Agent.update(:mi_lista, fn lista -> ["b" | lista] end)
Agent.update(:mi_lista, fn lista -> ["c" | lista] end)

IO.inspect(Agent.get(:mi_lista, & &1), label: "Lista")

Agent.stop(:mi_lista)

# ==========================================
# CACHE CON AGENT
# ==========================================

IO.puts("\n=== CACHE SIMPLE ===")

defmodule MiCache do
  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn map -> Map.get(map, key) end)
  end

  def put(key, value) do
    Agent.update(__MODULE__, fn map -> Map.put(map, key, value) end)
  end

  def delete(key) do
    Agent.update(__MODULE__, fn map -> Map.delete(map, key) end)
  end

  def all() do
    Agent.get(__MODULE__, fn map -> map end)
  end

  def clear() do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end
end

MiCache.start_link()

MiCache.put(:usuario, "Juan")
MiCache.put(:email, "juan@mail.com")
MiCache.put(:edad, 30)

IO.inspect(MiCache.get(:usuario), label: "Usuario")
IO.inspect(MiCache.all(), label: "Todo")

MiCache.delete(:edad)
IO.inspect(MiCache.all(), label: "Sin edad")

Agent.stop(MiCache)

# ==========================================
# CAST (ASINCRONO)
# ==========================================

IO.puts("\n=== OPERACIONES ASINCRONAS ===")

{:ok, agent} = Agent.start_link(fn -> 0 end)

# update es SINCRONO por defecto (espera que termine)
# Para operaciones async, usar cast

Agent.cast(agent, fn state -> state + 100 end)
Agent.cast(agent, fn state -> state + 200 end)

# Las operaciones async pueden no haber terminado aun
Process.sleep(10)

IO.inspect(Agent.get(agent, & &1), label: "Despues de casts")

Agent.stop(agent)

# ==========================================
# TIMEOUT
# ==========================================

IO.puts("\n=== TIMEOUT ===")

{:ok, agent} = Agent.start_link(fn -> :estado end)

# get y update aceptan timeout (default 5000ms)
valor = Agent.get(agent, fn s -> s end, 1000)  # timeout 1 segundo
IO.inspect(valor, label: "Con timeout")

Agent.stop(agent)

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n=== EDGE CASES ===")

{:ok, agent} = Agent.start_link(fn -> %{} end)

# La funcion en get/update se ejecuta EN el proceso del Agent
# Esto significa que si es lenta, bloquea al Agent

Agent.update(agent, fn state ->
  # Esto bloquea al agent por 100ms
  Process.sleep(100)
  Map.put(state, :key, :value)
end)

IO.puts("Una operacion lenta bloquea al agent")

# Para evitar, hacer el trabajo pesado AFUERA:
datos_procesados = Enum.map(1..1000, & &1 * 2)  # trabajo afuera
Agent.update(agent, fn state ->
  Map.put(state, :datos, datos_procesados)  # solo guardar
end)

IO.puts("Mejor: procesar afuera, solo guardar en el agent")

Agent.stop(agent)

# ==========================================
# AGENT vs GENSERVER
# ==========================================

IO.puts("\n=== AGENT vs GENSERVER ===")

IO.puts("""
AGENT:
- Solo para estado simple
- API minima: get, update, get_and_update
- Perfecto para: contadores, caches, flags

GENSERVER:
- Estado + logica compleja
- Callbacks personalizados
- Manejo de mensajes externos
- Perfecto para: servicios, workers, conexiones

REGLA:
- Si solo necesitas guardar/leer datos: AGENT
- Si necesitas procesar mensajes o logica: GENSERVER
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
FUNCIONES PRINCIPALES:
- Agent.start_link(fn -> estado_inicial end)
- Agent.start_link(fn -> estado end, name: :nombre)
- Agent.get(agent, fn state -> resultado end)
- Agent.update(agent, fn state -> nuevo_estado end)
- Agent.get_and_update(agent, fn s -> {retorno, nuevo} end)
- Agent.cast(agent, fn state -> nuevo_estado end)
- Agent.stop(agent)

PATRON COMUN:
defmodule MiEstado do
  def start_link(), do: Agent.start_link(fn -> inicial end, name: __MODULE__)
  def get(), do: Agent.get(__MODULE__, fn s -> s end)
  def update(valor), do: Agent.update(__MODULE__, fn _ -> valor end)
end
""")
