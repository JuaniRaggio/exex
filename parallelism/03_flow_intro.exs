# ==========================================
# FLOW - PROCESAMIENTO PARALELO DE DATOS
# ==========================================
#
# Flow es una libreria para procesamiento paralelo de datos.
# Es como Enum/Stream pero paralelizado automaticamente.
#
# NOTA: Flow es una dependencia externa.
# Para usarlo en un proyecto real:
#   mix.exs: {:flow, "~> 1.2"}
#
# Este archivo explica los CONCEPTOS aunque no podamos
# ejecutar Flow directamente sin un proyecto mix.

# ==========================================
# ENUM vs STREAM vs FLOW
# ==========================================

IO.puts("=== ENUM vs STREAM vs FLOW ===")

IO.puts("""
ENUM (eager, secuencial):
- Procesa toda la coleccion inmediatamente
- Crea listas intermedias en memoria
- Una operacion a la vez

  1..1000
  |> Enum.map(fn x -> x * 2 end)      # lista de 1000
  |> Enum.filter(fn x -> x > 500 end) # otra lista
  |> Enum.take(10)                    # solo 10!

STREAM (lazy, secuencial):
- Procesa elemento por elemento
- No crea listas intermedias
- Composicion de operaciones

  1..1000
  |> Stream.map(fn x -> x * 2 end)     # no ejecuta aun
  |> Stream.filter(fn x -> x > 500 end) # no ejecuta aun
  |> Enum.take(10)                      # ahora ejecuta, solo 10

FLOW (lazy, paralelo):
- Como Stream pero distribuido en multiples procesos
- Ideal para grandes volumenes de datos
- Particionado automatico

  1..1000
  |> Flow.from_enumerable()
  |> Flow.map(fn x -> x * 2 end)
  |> Flow.filter(fn x -> x > 500 end)
  |> Enum.take(10)
""")

# ==========================================
# COMO FUNCIONA FLOW
# ==========================================

IO.puts("\n=== COMO FUNCIONA FLOW ===")

IO.puts("""
Flow divide el trabajo en STAGES:

PRODUCTOR -> PARTITIONS -> CONSUMIDOR
    |            |
    |     +------+------+
    |     |      |      |
    +---> P1     P2     P3  (procesos paralelos)
          |      |      |
          +------+------+
                 |
                 v
              RESULTADO

1. PRODUCTOR: genera datos (enumerable, archivo, etc)
2. PARTITIONS: N procesos procesan en paralelo
3. CONSUMIDOR: recolecta resultados
""")

# ==========================================
# API DE FLOW (conceptual)
# ==========================================

IO.puts("\n=== API DE FLOW ===")

IO.puts("""
CREAR FLOW:
  Flow.from_enumerable(enumerable)
  Flow.from_enumerables([enum1, enum2, ...])

TRANSFORMAR:
  |> Flow.map(fn x -> x * 2 end)
  |> Flow.filter(fn x -> x > 0 end)
  |> Flow.flat_map(fn x -> [x, x+1] end)

PARTICIONAR (para reducir):
  |> Flow.partition(key: fn x -> x.category end)
  |> Flow.reduce(fn -> 0 end, fn x, acc -> acc + x end)

EJECUTAR:
  |> Enum.to_list()
  |> Flow.run()  # solo side effects
""")

# ==========================================
# EJEMPLO CONCEPTUAL: WORD COUNT
# ==========================================

IO.puts("\n=== EJEMPLO: WORD COUNT ===")

IO.puts("""
# Contar palabras en un archivo grande (pseudocodigo)

archivo
|> File.stream!()                        # leer linea por linea
|> Flow.from_enumerable()                # crear flow
|> Flow.flat_map(&String.split/1)        # dividir en palabras
|> Flow.partition()                      # agrupar palabras iguales
|> Flow.reduce(fn -> %{} end, fn word, acc ->
     Map.update(acc, word, 1, & &1 + 1)  # contar
   end)
|> Enum.to_list()                        # obtener resultado

Esto procesa el archivo en paralelo, cada partition
maneja un subset de palabras.
""")

# ==========================================
# SIMULACION SIN FLOW
# ==========================================

IO.puts("\n=== SIMULACION (sin Flow) ===")

# Podemos simular lo que hace Flow manualmente
defmodule PseudoFlow do
  # Dividir en N chunks, procesar en paralelo, combinar
  def parallel_map(enumerable, fun, num_partitions \\ 4) do
    enumerable
    |> Enum.chunk_every(ceil(Enum.count(enumerable) / num_partitions))
    |> Task.async_stream(fn chunk ->
         Enum.map(chunk, fun)
       end)
    |> Enum.flat_map(fn {:ok, results} -> results end)
  end

  def parallel_reduce(enumerable, acc_fn, reducer_fn, num_partitions \\ 4) do
    enumerable
    |> Enum.chunk_every(ceil(Enum.count(enumerable) / num_partitions))
    |> Task.async_stream(fn chunk ->
         Enum.reduce(chunk, acc_fn.(), reducer_fn)
       end)
    |> Enum.reduce(acc_fn.(), fn {:ok, partial}, acc ->
         # Combinar resultados parciales
         case {partial, acc} do
           {p, a} when is_number(p) and is_number(a) -> p + a
           {p, a} when is_map(p) and is_map(a) -> Map.merge(p, a, fn _, v1, v2 -> v1 + v2 end)
           _ -> partial
         end
       end)
  end
end

# Ejemplo: suma paralela
numeros = 1..10_000 |> Enum.to_list()

inicio = System.monotonic_time(:microsecond)
suma_seq = Enum.sum(numeros)
fin_seq = System.monotonic_time(:microsecond)

inicio = System.monotonic_time(:microsecond)
suma_par = PseudoFlow.parallel_reduce(numeros, fn -> 0 end, &+/2)
fin_par = System.monotonic_time(:microsecond)

IO.puts("Suma de 1..10000:")
IO.puts("  Secuencial: #{suma_seq} en #{fin_seq - inicio}us")
IO.puts("  Paralelo: #{suma_par} en #{fin_par - inicio}us")

# Ejemplo: word count simplificado
texto = """
hello world hello elixir world elixir elixir
functional programming functional elixir
""" |> String.split()

conteo = PseudoFlow.parallel_reduce(
  texto,
  fn -> %{} end,
  fn word, acc -> Map.update(acc, word, 1, & &1 + 1) end
)

IO.inspect(conteo, label: "Word count")

# ==========================================
# CUANDO USAR FLOW
# ==========================================

IO.puts("\n=== CUANDO USAR FLOW ===")

IO.puts("""
USAR FLOW CUANDO:
- Procesas datasets grandes (millones de items)
- Cada operacion es costosa (CPU o I/O)
- Los datos pueden procesarse independientemente
- Necesitas reducir/agregar resultados

NO USAR FLOW CUANDO:
- Dataset pequenio (< 10,000 items simples)
- Operaciones muy rapidas (overhead > beneficio)
- Dependencias entre elementos
- Ya estas en un contexto paralelo

ALTERNATIVAS:
- Task.async_stream: colecciones moderadas
- GenStage: pipelines complejos con backpressure
- Broadway: procesamiento de mensajes/eventos
""")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
FLOW:
- Libreria para procesamiento paralelo de datos
- Similar a Enum/Stream pero paralelizado
- Usa particiones para distribuir trabajo

CONCEPTOS CLAVE:
- Particiones: procesos que trabajan en paralelo
- Ventanas: agrupacion temporal de datos
- Stages: etapas del pipeline

PARA USAR:
  # mix.exs
  defp deps do
    [{:flow, "~> 1.2"}]
  end

  # codigo
  Flow.from_enumerable(data)
  |> Flow.map(...)
  |> Flow.partition()
  |> Flow.reduce(...)
  |> Enum.to_list()
""")
