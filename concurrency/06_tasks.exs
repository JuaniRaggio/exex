# ==========================================
# TASKS - TAREAS ASINCRONAS
# ==========================================
#
# Task es una abstraccion para ejecutar trabajo en background
# y (opcionalmente) obtener el resultado despues.
#
# Perfecto para:
# - Operaciones I/O en paralelo
# - Trabajo pesado sin bloquear
# - Timeouts en operaciones

# ==========================================
# TASK BASICO - ASYNC/AWAIT
# ==========================================

IO.puts("=== TASK ASYNC/AWAIT ===")

# Task.async inicia tarea en background
tarea = Task.async(fn ->
  Process.sleep(100)  # Simular trabajo
  42
end)

IO.inspect(tarea, label: "Task struct")

# Mientras la tarea corre, podemos hacer otras cosas
IO.puts("Haciendo otras cosas mientras la tarea corre...")

# Task.await espera el resultado
resultado = Task.await(tarea)
IO.inspect(resultado, label: "Resultado")

# ==========================================
# TIMEOUT EN AWAIT
# ==========================================

IO.puts("\n=== TIMEOUT ===")

tarea_lenta = Task.async(fn ->
  Process.sleep(5000)
  :resultado
end)

# await con timeout (default 5000ms)
try do
  Task.await(tarea_lenta, 100)  # timeout de 100ms
catch
  :exit, {:timeout, _} ->
    IO.puts("Timeout! La tarea tardo demasiado")
end

# La tarea sigue corriendo, podemos cancelarla
Task.shutdown(tarea_lenta)

# ==========================================
# MULTIPLES TAREAS EN PARALELO
# ==========================================

IO.puts("\n=== TAREAS EN PARALELO ===")

# Iniciar varias tareas simultaneamente
tareas = for i <- 1..5 do
  Task.async(fn ->
    Process.sleep(:rand.uniform(200))
    i * 10
  end)
end

IO.puts("5 tareas iniciadas en paralelo")

# Esperar todas las tareas
resultados = Task.await_many(tareas)
IO.inspect(resultados, label: "Resultados")

# ==========================================
# TASK.YIELD - NO BLOQUEANTE
# ==========================================

IO.puts("\n=== TASK.YIELD ===")

tarea = Task.async(fn ->
  Process.sleep(200)
  :listo
end)

# yield revisa si termino sin bloquear
caso1 = Task.yield(tarea, 50)  # espera 50ms
IO.inspect(caso1, label: "Despues de 50ms")

caso2 = Task.yield(tarea, 200)  # espera 200ms mas
IO.inspect(caso2, label: "Despues de 200ms mas")

# Si ya obtuvimos resultado, yield retorna nil
caso3 = Task.yield(tarea, 0)
IO.inspect(caso3, label: "Tarea ya terminada")

# ==========================================
# YIELD_MANY - MULTIPLES TAREAS
# ==========================================

IO.puts("\n=== YIELD_MANY ===")

tareas = [
  Task.async(fn -> Process.sleep(50); :rapida end),
  Task.async(fn -> Process.sleep(300); :lenta end),
  Task.async(fn -> Process.sleep(100); :media end)
]

# Revisar cuales terminaron
resultados = Task.yield_many(tareas, 150)

Enum.each(resultados, fn {task, result} ->
  case result do
    {:ok, valor} -> IO.puts("Tarea termino: #{inspect(valor)}")
    nil -> IO.puts("Tarea aun corriendo, cancelando...")
           Task.shutdown(task, :brutal_kill)
  end
end)

# ==========================================
# TASK.START vs TASK.ASYNC
# ==========================================

IO.puts("\n=== START vs ASYNC ===")

# async: queremos el resultado despues
tarea_con_resultado = Task.async(fn -> :resultado end)
_resultado = Task.await(tarea_con_resultado)

# start_link: fire-and-forget (no nos importa el resultado)
Task.start_link(fn ->
  IO.puts("Tarea en background sin resultado")
end)

Process.sleep(50)

IO.puts("""

DIFERENCIA:
- Task.async/await: cuando necesitas el resultado
- Task.start/start_link: fire-and-forget
""")

# ==========================================
# EJEMPLO PRACTICO: REQUESTS EN PARALELO
# ==========================================

IO.puts("\n=== REQUESTS EN PARALELO ===")

# Simular llamadas HTTP
defmodule FakeHTTP do
  def get(url) do
    delay = :rand.uniform(200)
    Process.sleep(delay)
    {:ok, "Respuesta de #{url} (#{delay}ms)"}
  end
end

urls = [
  "https://api1.example.com",
  "https://api2.example.com",
  "https://api3.example.com",
  "https://api4.example.com"
]

IO.puts("Iniciando #{length(urls)} requests en paralelo...")
inicio = System.monotonic_time(:millisecond)

tareas = Enum.map(urls, fn url ->
  Task.async(fn -> FakeHTTP.get(url) end)
end)

resultados = Task.await_many(tareas, 5000)
fin = System.monotonic_time(:millisecond)

Enum.each(resultados, fn {:ok, resp} ->
  IO.puts("  #{resp}")
end)

IO.puts("Tiempo total: #{fin - inicio}ms (en serie hubiera sido ~400ms)")

# ==========================================
# TASK SUPERVISOR
# ==========================================

IO.puts("\n=== TASK SUPERVISOR ===")

# Para produccion, es mejor usar Task.Supervisor
# Permite reintentos, limites, y mejor supervision

# Iniciar un supervisor de tareas
{:ok, sup} = Task.Supervisor.start_link()

# Ejecutar tarea bajo supervision
tarea = Task.Supervisor.async(sup, fn ->
  Process.sleep(50)
  :supervisado
end)

IO.inspect(Task.await(tarea), label: "Resultado supervisado")

# Fire-and-forget supervisado
Task.Supervisor.start_child(sup, fn ->
  IO.puts("Tarea supervisada en background")
end)

Process.sleep(100)

# ==========================================
# ASYNC_STREAM - PROCESAMIENTO EN PARALELO
# ==========================================

IO.puts("\n=== ASYNC_STREAM ===")

# Procesar lista en paralelo con control de concurrencia
items = 1..10

resultado = items
  |> Task.async_stream(fn i ->
       Process.sleep(50)
       i * 2
     end, max_concurrency: 3)  # maximo 3 tareas simultaneas
  |> Enum.map(fn {:ok, val} -> val end)

IO.inspect(resultado, label: "Procesados en paralelo (max 3)")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n=== EDGE CASES ===")

# Si una tarea crashea, await tambien crashea
tarea_mala = Task.async(fn ->
  raise "Error en tarea!"
end)

try do
  Task.await(tarea_mala)
rescue
  e -> IO.puts("Tarea crasheo: #{inspect(e)}")
end

# await dos veces falla
tarea = Task.async(fn -> :ok end)
Task.await(tarea)
try do
  Task.await(tarea)
catch
  :exit, _ -> IO.puts("No se puede await dos veces")
end

# La tarea debe iniciarse en el mismo proceso (o usar TaskSupervisor)
IO.puts("Task.async debe usarse desde el proceso que hara await")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
FUNCIONES PRINCIPALES:
- Task.async(fn) + Task.await(task)  -> ejecutar y obtener resultado
- Task.await(task, timeout)          -> con timeout
- Task.await_many(tasks)             -> esperar multiples
- Task.yield(task, timeout)          -> revisar sin bloquear
- Task.yield_many(tasks, timeout)    -> revisar multiples
- Task.shutdown(task)                -> cancelar tarea
- Task.start_link(fn)                -> fire-and-forget

PARA PRODUCCION:
- Task.Supervisor.start_link()
- Task.Supervisor.async(sup, fn)
- Task.async_stream(enum, fn, opts)

PATRON COMUN:
1. Iniciar N tareas con Task.async
2. Esperar todas con Task.await_many
3. Procesar resultados
""")
