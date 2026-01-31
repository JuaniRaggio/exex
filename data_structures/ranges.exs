# ==========================================
# RANGES EN ELIXIR
# ==========================================
# Los Ranges representan una secuencia de enteros
# NO almacenan todos los valores en memoria
# Solo guardan: inicio, fin y step
# Son lazy - los valores se generan cuando se necesitan
# Perfectos para iteraciones y generacion de secuencias

# ==========================================
# CREACION BASICA
# ==========================================

# Rango inclusivo (incluye ambos extremos)
rango = 1..5
IO.inspect(rango, label: "Rango 1..5")

# Verificar tipo
IO.inspect(is_struct(rango, Range), label: "Es un Range?")

# Los rangos son structs con first, last y step
IO.inspect(rango.first, label: "first")
IO.inspect(rango.last, label: "last")
IO.inspect(rango.step, label: "step")

# ==========================================
# TIPOS DE RANGOS
# ==========================================

IO.puts("\n--- TIPOS DE RANGOS ---")

# Ascendente (default step = 1)
ascendente = 1..10
IO.inspect(Enum.to_list(ascendente), label: "Ascendente 1..10")

# Descendente (step = -1)
descendente = 10..1//-1
IO.inspect(Enum.to_list(descendente), label: "Descendente 10..1//-1")

# IMPORTANTE: sin //-1, un rango "invertido" esta VACIO!
invertido_sin_step = 10..1
IO.inspect(Enum.to_list(invertido_sin_step), label: "10..1 SIN step (VACIO!)")

# Rango exclusivo (NO incluye el ultimo)
exclusivo = 1..5//1
IO.inspect(Enum.to_list(exclusivo), label: "1..5//1 (inclusivo)")

# En Elixir 1.12+, usar first..last//step
con_step = 0..10//2
IO.inspect(Enum.to_list(con_step), label: "0..10//2 (de 2 en 2)")

# Step negativo
pares_desc = 10..0//-2
IO.inspect(Enum.to_list(pares_desc), label: "10..0//-2")

# ==========================================
# RANGOS DE UN SOLO ELEMENTO
# ==========================================

IO.puts("\n--- CASOS ESPECIALES ---")

# Rango de un elemento
uno = 5..5
IO.inspect(Enum.to_list(uno), label: "5..5 (un elemento)")

# Rango vacio (cuando step va en direccion contraria)
vacio = 1..5//-1
IO.inspect(Enum.to_list(vacio), label: "1..5//-1 (vacio)")

# ==========================================
# OPERACIONES CON Enum
# ==========================================

IO.puts("\n--- OPERACIONES CON Enum ---")

rango = 1..10

# Convertir a lista
IO.inspect(Enum.to_list(rango), label: "to_list")

# map
cuadrados = Enum.map(rango, fn x -> x * x end)
IO.inspect(cuadrados, label: "map cuadrados")

# filter
pares = Enum.filter(rango, fn x -> rem(x, 2) == 0 end)
IO.inspect(pares, label: "filter pares")

# reduce
suma = Enum.reduce(rango, 0, fn x, acc -> x + acc end)
IO.inspect(suma, label: "reduce suma")

# Funciones de agregacion
IO.inspect(Enum.sum(rango), label: "sum")
IO.inspect(Enum.count(rango), label: "count")
IO.inspect(Enum.min(rango), label: "min")
IO.inspect(Enum.max(rango), label: "max")

# member?
IO.inspect(Enum.member?(rango, 5), label: "member?(5)")
IO.inspect(Enum.member?(rango, 50), label: "member?(50)")

# take y drop
IO.inspect(Enum.take(rango, 3), label: "take(3)")
IO.inspect(Enum.drop(rango, 7), label: "drop(7)")

# at
IO.inspect(Enum.at(rango, 0), label: "at(0)")
IO.inspect(Enum.at(rango, 4), label: "at(4)")

# random
IO.inspect(Enum.random(rango), label: "random (cambia cada vez)")

# ==========================================
# USO EN COMPREHENSIONS (for)
# ==========================================

IO.puts("\n--- COMPREHENSIONS ---")

# Generacion simple
lista = for x <- 1..5, do: x * 2
IO.inspect(lista, label: "for x <- 1..5, do: x*2")

# Con filtro
filtrado = for x <- 1..20, rem(x, 3) == 0, do: x
IO.inspect(filtrado, label: "Multiplos de 3 hasta 20")

# Combinaciones (producto cartesiano)
combinaciones = for x <- 1..3, y <- 1..3, do: {x, y}
IO.inspect(combinaciones, label: "Todas las combinaciones")

# Con filtro en combinaciones
triangulo = for x <- 1..3, y <- 1..x, do: {x, y}
IO.inspect(triangulo, label: "Triangulo inferior")

# Generar string
letras = for c <- ?a..?e, do: <<c>>
IO.inspect(letras, label: "Letras a-e")

# ==========================================
# MODULO Range
# ==========================================

IO.puts("\n--- MODULO Range ---")

rango = 1..10//2

# Range.size/1 - cantidad de elementos
IO.inspect(Range.size(rango), label: "Range.size")

# Range.disjoint?/2 - no se superponen?
r1 = 1..5
r2 = 6..10
r3 = 4..7
IO.inspect(Range.disjoint?(r1, r2), label: "disjoint?(1..5, 6..10)")
IO.inspect(Range.disjoint?(r1, r3), label: "disjoint?(1..5, 4..7)")

# Range.new/2 y Range.new/3
creado = Range.new(1, 10)
IO.inspect(creado, label: "Range.new(1, 10)")

con_step = Range.new(1, 10, 3)
IO.inspect(con_step, label: "Range.new(1, 10, 3)")
IO.inspect(Enum.to_list(con_step), label: "Lista de 1..10//3")

# ==========================================
# PATTERN MATCHING
# ==========================================

IO.puts("\n--- PATTERN MATCHING ---")

rango = 1..10//2

# Extraer componentes
first..last//step = rango
IO.inspect({first, last, step}, label: "Componentes extraidos")

# Match en case
case 1..5 do
  1..5 -> IO.puts("Es exactamente 1..5")
  1.._ -> IO.puts("Empieza en 1")
  _ -> IO.puts("Otro rango")
end

# Verificar si un numero esta en rango (con in)
x = 5
IO.inspect(x in 1..10, label: "5 in 1..10")
IO.inspect(x in 10..20, label: "5 in 10..20")

# ==========================================
# COMPARACION CON LISTAS
# ==========================================

IO.puts("\n--- RANGO vs LISTA ---")

# Un rango NO es una lista
rango = 1..1000000
lista = [1, 2, 3, 4, 5]

IO.inspect(is_list(rango), label: "Rango es lista?")
IO.inspect(is_list(lista), label: "Lista es lista?")

# Pero ambos son Enumerable
IO.inspect(Enumerable.impl_for(rango) != nil, label: "Rango es Enumerable?")

# VENTAJA: Rango usa memoria constante O(1)
# La lista de 1..1000000 usaria mucha memoria
# El rango solo guarda: {1, 1000000, 1}

IO.puts("\nRANGO 1..1000000:")
IO.puts("  Memoria: O(1) - solo 3 numeros")
IO.puts("  Enum.count: #{Enum.count(rango)}")
IO.puts("  Enum.member?(500000): #{Enum.member?(rango, 500000)}")

# ==========================================
# STREAM (lazy) vs ENUM (eager)
# ==========================================

IO.puts("\n--- LAZY vs EAGER ---")

# Enum es EAGER - procesa todo inmediatamente
# Stream es LAZY - procesa elemento por elemento

# Esto crea una lista intermedia grande:
# Enum.map(1..1000000, fn x -> x * 2 end) |> Enum.take(5)

# Esto es mas eficiente con Stream:
resultado = 1..1000000
  |> Stream.map(fn x -> x * 2 end)
  |> Enum.take(5)
IO.inspect(resultado, label: "Stream.map + take(5)")

# Stream procesa solo lo necesario
IO.puts("Stream solo proceso 5 elementos, no 1000000")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

# Rango vacio
vacio = 5..1//1  # step positivo pero last < first
IO.inspect(Enum.to_list(vacio), label: "Rango vacio (5..1//1)")
IO.inspect(Range.size(vacio), label: "Size de rango vacio")

# Step que no llega exacto al final
no_exacto = 1..10//3
IO.inspect(Enum.to_list(no_exacto), label: "1..10//3 (no llega a 10)")

# Step 0 - NO PERMITIDO
# 1..10//0  # ArgumentError!
IO.puts("CUIDADO: step 0 causa ArgumentError")

# Numeros negativos
negativos = -5..-1
IO.inspect(Enum.to_list(negativos), label: "-5..-1")

# Cruzando el cero
cruzando = -3..3
IO.inspect(Enum.to_list(cruzando), label: "-3..3")

# Rango muy grande - NO lo conviertas a lista!
grande = 1..1000000000
IO.inspect(Range.size(grande), label: "Size de rango enorme")
IO.inspect(Enum.member?(grande, 500000000), label: "member? funciona bien")
# Enum.to_list(grande)  # Crashearia por memoria!
IO.puts("CUIDADO: to_list en rangos enormes consume mucha memoria")

# Floats NO funcionan
# 1.0..5.0  # ArgumentError!
IO.puts("CUIDADO: Ranges solo funcionan con integers")

# ==========================================
# CASOS DE USO PRACTICOS
# ==========================================

IO.puts("\n--- CASOS DE USO ---")

# 1. Indices para acceso a listas
lista = [:a, :b, :c, :d, :e]
for i <- 0..(length(lista) - 1) do
  IO.puts("  Indice #{i}: #{Enum.at(lista, i)}")
end

# 2. Generacion de datos de prueba
ids_prueba = Enum.to_list(1..10)
IO.inspect(ids_prueba, label: "IDs de prueba")

# 3. Paginacion
pagina = 3
por_pagina = 10
offset = (pagina - 1) * por_pagina
rango_pagina = (offset + 1)..(offset + por_pagina)
IO.inspect(rango_pagina, label: "Rango para pagina 3")

# 4. Generacion de caracteres
mayusculas = for c <- ?A..?Z, do: <<c>>
IO.inspect(mayusculas, label: "Abecedario mayusculas")

# 5. Countdown
cuenta_regresiva = for n <- 10..1//-1, do: n
IO.inspect(cuenta_regresiva, label: "Cuenta regresiva")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n--- RESUMEN ---")

IO.puts("""
SINTAXIS:
- first..last         : rango inclusivo, step = 1
- first..last//step   : rango con step especifico
- first..last//-1     : rango descendente

CARACTERISTICAS:
- Solo integers (no floats)
- Memoria O(1) - no guarda todos los valores
- Lazy - valores generados al iterar
- Implementa Enumerable

MODULO Range:
- Range.size/1: cantidad de elementos
- Range.disjoint?/2: no se superponen?
- Range.new/2, new/3: crear programaticamente

OPERADOR in:
- x in 1..10: verifica pertenencia

EDGE CASES:
- 10..1 SIN step es VACIO (necesita 10..1//-1)
- Step 0 causa error
- Solo integers permitidos
- Cuidado con to_list en rangos grandes
""")
