# ==========================================
# INTRODUCCION AL PARALELISMO EN ELIXIR
# ==========================================
#
# CONCURRENCIA vs PARALELISMO:
#
# CONCURRENCIA:
# - Multiples tareas "en progreso" al mismo tiempo
# - Pueden alternarse en un solo CPU
# - Sobre ESTRUCTURA del programa
#
# PARALELISMO:
# - Multiples tareas ejecutandose REALMENTE al mismo tiempo
# - Requiere multiples CPUs/cores
# - Sobre EJECUCION del programa
#
# Elixir soporta AMBOS de forma nativa gracias a la BEAM.

# ==========================================
# SCHEDULERS DE LA BEAM
# ==========================================

IO.puts("=== SCHEDULERS ===")

# La BEAM tiene N schedulers, tipicamente = numero de cores
schedulers = System.schedulers()
schedulers_online = System.schedulers_online()

IO.puts("Schedulers totales: #{schedulers}")
IO.puts("Schedulers online: #{schedulers_online}")

# Cada scheduler puede ejecutar procesos en paralelo
# Si tienes 8 cores, puedes tener 8 procesos corriendo
# REALMENTE al mismo tiempo

# ==========================================
# DEMOSTRACION DE PARALELISMO REAL
# ==========================================

IO.puts("\n=== PARALELISMO EN ACCION ===")

# Funcion CPU-intensiva (calcular si es primo)
es_primo = fn n ->
  cond do
    n < 2 -> false
    n == 2 -> true
    rem(n, 2) == 0 -> false
    true ->
      limite = trunc(:math.sqrt(n))
      Enum.all?(3..limite//2, fn i -> rem(n, i) != 0 end)
  end
end

# Numeros grandes para hacer trabajo real
numeros = [
  10_000_019, 10_000_079, 10_000_103, 10_000_121,
  10_000_139, 10_000_141, 10_000_169, 10_000_189
]

# VERSION SECUENCIAL
IO.puts("\nVersion SECUENCIAL:")
inicio_seq = System.monotonic_time(:millisecond)

resultados_seq = Enum.map(numeros, fn n ->
  {n, es_primo.(n)}
end)

fin_seq = System.monotonic_time(:millisecond)
IO.puts("Tiempo: #{fin_seq - inicio_seq}ms")

# VERSION PARALELA con Task.async_stream
IO.puts("\nVersion PARALELA:")
inicio_par = System.monotonic_time(:millisecond)

resultados_par = numeros
  |> Task.async_stream(fn n -> {n, es_primo.(n)} end, max_concurrency: 8)
  |> Enum.map(fn {:ok, resultado} -> resultado end)

fin_par = System.monotonic_time(:millisecond)
IO.puts("Tiempo: #{fin_par - inicio_par}ms")

# Speedup
speedup = (fin_seq - inicio_seq) / max(fin_par - inicio_par, 1)
IO.puts("Speedup: #{Float.round(speedup, 2)}x")

# ==========================================
# CUANDO EL PARALELISMO AYUDA
# ==========================================

IO.puts("\n=== CUANDO PARALELIZAR ===")

IO.puts("""
PARALELISMO AYUDA CON:
- Trabajo CPU-intensivo (calculos, transformaciones)
- Operaciones I/O independientes (HTTP, archivos, DB)
- Procesamiento de listas grandes
- Cualquier tarea que pueda dividirse

PARALELISMO NO AYUDA SI:
- El trabajo es muy pequenio (overhead > beneficio)
- Las tareas dependen unas de otras
- Hay un cuello de botella externo (1 conexion DB)
- El trabajo ya es muy rapido

REGLA GENERAL:
- Si tarda menos de ~1ms, no vale la pena paralelizar
- Si hay dependencias secuenciales, no se puede paralelizar
""")

# ==========================================
# OVERHEAD DEL PARALELISMO
# ==========================================

IO.puts("\n=== OVERHEAD ===")

# Trabajo muy pequenio: el overhead de spawn supera el beneficio
trabajo_pequenio = fn -> 1 + 1 end

IO.puts("Trabajo trivial (1+1):")

inicio = System.monotonic_time(:microsecond)
for _ <- 1..1000, do: trabajo_pequenio.()
fin = System.monotonic_time(:microsecond)
IO.puts("  Secuencial: #{fin - inicio} microsegundos")

inicio = System.monotonic_time(:microsecond)
1..1000
|> Task.async_stream(fn _ -> trabajo_pequenio.() end)
|> Enum.to_list()
fin = System.monotonic_time(:microsecond)
IO.puts("  Paralelo: #{fin - inicio} microsegundos")

IO.puts("  (Paralelo es MAS LENTO para trabajo trivial!)")

# ==========================================
# VISUALIZANDO PARALELISMO
# ==========================================

IO.puts("\n=== VISUALIZANDO EJECUCION ===")

# Mostrar que procesos corren en paralelo
trabajo_visible = fn id ->
  IO.puts("[#{id}] Inicio en scheduler #{:erlang.system_info(:scheduler_id)}")
  Process.sleep(100)
  IO.puts("[#{id}] Fin")
  id
end

IO.puts("Ejecutando 4 tareas en paralelo:")
resultados = 1..4
  |> Task.async_stream(trabajo_visible, max_concurrency: 4, ordered: false)
  |> Enum.to_list()

# Los "Inicio" se imprimen casi al mismo tiempo
# porque realmente corren en paralelo

# ==========================================
# max_concurrency
# ==========================================

IO.puts("\n=== CONTROL DE CONCURRENCIA ===")

# max_concurrency limita cuantas tareas corren simultaneamente
# Util para no sobrecargar recursos (conexiones DB, APIs, etc)

trabajo = fn i ->
  Process.sleep(100)
  i
end

IO.puts("10 tareas, max_concurrency: 2 (500ms esperado):")
inicio = System.monotonic_time(:millisecond)
1..10
|> Task.async_stream(trabajo, max_concurrency: 2)
|> Enum.to_list()
fin = System.monotonic_time(:millisecond)
IO.puts("Tiempo: #{fin - inicio}ms")

IO.puts("\n10 tareas, max_concurrency: 10 (100ms esperado):")
inicio = System.monotonic_time(:millisecond)
1..10
|> Task.async_stream(trabajo, max_concurrency: 10)
|> Enum.to_list()
fin = System.monotonic_time(:millisecond)
IO.puts("Tiempo: #{fin - inicio}ms")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
PARALELISMO EN ELIXIR:
- La BEAM usa N schedulers (tipicamente = cores)
- Procesos se distribuyen automaticamente entre schedulers
- Task.async_stream es la forma mas facil de paralelizar

HERRAMIENTAS:
- Task.async/await: tareas individuales
- Task.async_stream: procesar colecciones en paralelo
- Flow (libreria): procesamiento paralelo de datos

CONSIDERACIONES:
- Hay overhead en crear procesos
- No todo puede/debe paralelizarse
- max_concurrency controla uso de recursos

SIGUIENTE: ver 02_parallel_patterns.exs para patrones comunes
""")
