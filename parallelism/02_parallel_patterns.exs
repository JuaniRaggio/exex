# ==========================================
# PATRONES DE PARALELISMO EN ELIXIR
# ==========================================
#
# Este archivo muestra patrones comunes para aprovechar
# el paralelismo en aplicaciones reales.

# ==========================================
# PATRON 1: MAP PARALELO
# ==========================================

IO.puts("=== MAP PARALELO ===")

# El patron mas comun: aplicar funcion a cada elemento en paralelo

defmodule ParallelMap do
  # Usando Task
  def map_tasks(list, fun) do
    list
    |> Enum.map(fn item -> Task.async(fn -> fun.(item) end) end)
    |> Enum.map(&Task.await/1)
  end

  # Usando async_stream (preferido, tiene control de concurrencia)
  def map_stream(list, fun, opts \\ []) do
    list
    |> Task.async_stream(fun, opts)
    |> Enum.map(fn {:ok, result} -> result end)
  end
end

lista = [1, 2, 3, 4, 5]
transformacion = fn x ->
  Process.sleep(100)
  x * x
end

IO.puts("Cuadrados en paralelo:")
resultado = ParallelMap.map_stream(lista, transformacion)
IO.inspect(resultado, label: "Resultado")

# ==========================================
# PATRON 2: FILTER PARALELO
# ==========================================

IO.puts("\n=== FILTER PARALELO ===")

defmodule ParallelFilter do
  def filter(list, predicate, opts \\ []) do
    list
    |> Task.async_stream(fn item ->
         {item, predicate.(item)}
       end, opts)
    |> Stream.filter(fn {:ok, {_item, keep?}} -> keep? end)
    |> Enum.map(fn {:ok, {item, _}} -> item end)
  end
end

# Filtrar numeros donde una condicion "cara" es verdadera
numeros = 1..20 |> Enum.to_list()

es_divisible_por_3 = fn n ->
  Process.sleep(50)  # Simular calculo costoso
  rem(n, 3) == 0
end

IO.puts("Filtrando divisibles por 3:")
filtrados = ParallelFilter.filter(numeros, es_divisible_por_3)
IO.inspect(filtrados, label: "Divisibles por 3")

# ==========================================
# PATRON 3: REDUCE CON TRABAJO PARALELO
# ==========================================

IO.puts("\n=== REDUCE PARALELO ===")

# Reduce no es directamente paralelizable, pero podemos:
# 1. Dividir el trabajo en chunks
# 2. Procesar chunks en paralelo
# 3. Combinar resultados

defmodule ParallelReduce do
  def sum(list, chunk_size \\ 100) do
    list
    |> Enum.chunk_every(chunk_size)
    |> Task.async_stream(fn chunk -> Enum.sum(chunk) end)
    |> Enum.reduce(0, fn {:ok, partial}, acc -> partial + acc end)
  end
end

numeros_grandes = 1..10_000 |> Enum.to_list()

IO.puts("Suma paralela de 1..10000:")
suma = ParallelReduce.sum(numeros_grandes, 1000)
IO.inspect(suma, label: "Suma")

# ==========================================
# PATRON 4: PRODUCER-CONSUMER
# ==========================================

IO.puts("\n=== PRODUCER-CONSUMER ===")

# Un proceso produce datos, otros los consumen

defmodule ProducerConsumer do
  def run(items, num_consumers, consumer_fn) do
    # Crear cola compartida (Agent simple)
    {:ok, queue} = Agent.start_link(fn -> items end)

    # Funcion para obtener siguiente item
    get_next = fn ->
      Agent.get_and_update(queue, fn
        [] -> {:done, []}
        [h | t] -> {h, t}
      end)
    end

    # Funcion de worker
    worker = fn ->
      Stream.repeatedly(get_next)
      |> Stream.take_while(fn item -> item != :done end)
      |> Enum.map(consumer_fn)
    end

    # Ejecutar N consumers en paralelo
    1..num_consumers
    |> Enum.map(fn _ -> Task.async(worker) end)
    |> Enum.flat_map(&Task.await(&1, :infinity))
  end
end

items = 1..20 |> Enum.to_list()
procesar = fn x ->
  Process.sleep(50)
  x * 2
end

IO.puts("4 consumers procesando 20 items:")
resultados = ProducerConsumer.run(items, 4, procesar)
IO.inspect(resultados, label: "Resultados")

# ==========================================
# PATRON 5: SCATTER-GATHER
# ==========================================

IO.puts("\n=== SCATTER-GATHER ===")

# Enviar trabajo a multiples "workers" y recolectar resultados

defmodule ScatterGather do
  def process(items, worker_fn, num_workers \\ 4) do
    # Dividir items entre workers
    chunks = Enum.chunk_every(items, ceil(length(items) / num_workers))

    # Scatter: enviar a workers
    tasks = Enum.map(chunks, fn chunk ->
      Task.async(fn ->
        Enum.map(chunk, worker_fn)
      end)
    end)

    # Gather: recolectar resultados
    tasks
    |> Enum.flat_map(&Task.await(&1, :infinity))
  end
end

items = 1..12 |> Enum.to_list()
trabajo = fn x ->
  Process.sleep(50)
  x * x
end

IO.puts("Scatter-Gather con 3 workers:")
resultados = ScatterGather.process(items, trabajo, 3)
IO.inspect(resultados, label: "Resultados")

# ==========================================
# PATRON 6: PIPELINE PARALELO
# ==========================================

IO.puts("\n=== PIPELINE PARALELO ===")

# Cada etapa del pipeline procesa en paralelo

defmodule ParallelPipeline do
  def run(items, stages, opts \\ []) do
    Enum.reduce(stages, items, fn stage_fn, data ->
      data
      |> Task.async_stream(stage_fn, opts)
      |> Enum.map(fn {:ok, result} -> result end)
    end)
  end
end

numeros = 1..10 |> Enum.to_list()

# Cada etapa hace trabajo
etapa1 = fn x -> Process.sleep(30); x + 1 end    # +1
etapa2 = fn x -> Process.sleep(30); x * 2 end    # *2
etapa3 = fn x -> Process.sleep(30); x - 5 end    # -5

IO.puts("Pipeline: +1, *2, -5")
resultado = ParallelPipeline.run(numeros, [etapa1, etapa2, etapa3], max_concurrency: 4)
IO.inspect(resultado, label: "Resultado")

# ==========================================
# PATRON 7: TIMEOUT Y FALLBACK
# ==========================================

IO.puts("\n=== TIMEOUT Y FALLBACK ===")

defmodule ParallelWithTimeout do
  def map_with_fallback(items, fun, timeout, fallback) do
    items
    |> Enum.map(fn item -> Task.async(fn -> fun.(item) end) end)
    |> Enum.map(fn task ->
         case Task.yield(task, timeout) do
           {:ok, result} -> result
           nil ->
             Task.shutdown(task, :brutal_kill)
             fallback
         end
       end)
  end
end

# Algunas operaciones son lentas
operacion = fn x ->
  delay = if rem(x, 3) == 0, do: 500, else: 50
  Process.sleep(delay)
  x * 10
end

IO.puts("Operacion con timeout 100ms:")
resultados = ParallelWithTimeout.map_with_fallback(
  1..9 |> Enum.to_list(),
  operacion,
  100,
  :timeout
)
IO.inspect(resultados, label: "Resultados (algunos con timeout)")

# ==========================================
# PATRON 8: RACE (PRIMER RESULTADO)
# ==========================================

IO.puts("\n=== RACE ===")

defmodule Race do
  def first(funs) do
    parent = self()

    pids = Enum.map(funs, fn fun ->
      spawn_link(fn ->
        result = fun.()
        send(parent, {:result, self(), result})
      end)
    end)

    receive do
      {:result, _pid, result} ->
        # Matar los demas
        Enum.each(pids, fn pid -> Process.exit(pid, :kill) end)
        result
    end
  end
end

# Simular multiples fuentes de datos, usar la mas rapida
fuentes = [
  fn -> Process.sleep(300); {:fuente_a, "datos A"} end,
  fn -> Process.sleep(100); {:fuente_b, "datos B"} end,
  fn -> Process.sleep(200); {:fuente_c, "datos C"} end
]

IO.puts("Carrera entre 3 fuentes:")
ganador = Race.first(fuentes)
IO.inspect(ganador, label: "Ganador (el mas rapido)")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN DE PATRONES ===")

IO.puts("""
PATRONES COMUNES:

1. MAP PARALELO
   - Aplicar funcion a lista en paralelo
   - Task.async_stream con max_concurrency

2. FILTER PARALELO
   - Evaluar predicado en paralelo
   - Filtrar basado en resultados

3. REDUCE PARALELO
   - Dividir en chunks, procesar, combinar

4. PRODUCER-CONSUMER
   - Cola de trabajo + N workers

5. SCATTER-GATHER
   - Dividir trabajo, distribuir, recolectar

6. PIPELINE PARALELO
   - Cada etapa procesa en paralelo

7. TIMEOUT + FALLBACK
   - Yield con timeout, valor default si falla

8. RACE
   - Ejecutar multiples, tomar el primero

SIGUIENTE: ver 03_flow.exs para procesamiento de datos
""")
