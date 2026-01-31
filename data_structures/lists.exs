# ==========================================
# LISTAS EN ELIXIR
# ==========================================
# Las listas en Elixir son linked lists (listas enlazadas)
# Esto significa que acceder al primer elemento es O(1)
# pero acceder al ultimo elemento es O(n)
# Son INMUTABLES como todo en Elixir

# ==========================================
# CREACION BASICA
# ==========================================

lista_vacia = []
lista_numeros = [1, 2, 3, 4, 5]
lista_mixta = [1, "hola", :atomo, 3.14, true]

IO.inspect(lista_vacia, label: "Lista vacia")
IO.inspect(lista_numeros, label: "Lista de numeros")
IO.inspect(lista_mixta, label: "Lista mixta (cualquier tipo)")

# ==========================================
# OPERACIONES BASICAS
# ==========================================

# Concatenacion con ++
lista_a = [1, 2, 3]
lista_b = [4, 5, 6]
concatenada = lista_a ++ lista_b
IO.inspect(concatenada, label: "Concatenacion ++")

# Resta de listas con --
# Remueve la PRIMERA ocurrencia de cada elemento
resta = [1, 2, 2, 3, 2, 4] -- [2, 4]
IO.inspect(resta, label: "Resta -- (quita primera ocurrencia)")

# Head (primer elemento) y Tail (resto de la lista)
[head | tail] = [1, 2, 3, 4, 5]
IO.inspect(head, label: "Head (cabeza)")
IO.inspect(tail, label: "Tail (cola)")

# Prepending (agregar al inicio) - MUY EFICIENTE O(1)
nueva_lista = [0 | [1, 2, 3]]
IO.inspect(nueva_lista, label: "Prepend con |")

# ==========================================
# FUNCIONES DEL MODULO List
# ==========================================

IO.puts("\n--- Funciones de List ---")

# List.first y List.last
IO.inspect(List.first([1, 2, 3]), label: "List.first")
IO.inspect(List.last([1, 2, 3]), label: "List.last")

# List.flatten - aplana listas anidadas
anidada = [[1, 2], [3, [4, 5]]]
IO.inspect(List.flatten(anidada), label: "List.flatten")

# List.zip - combina listas en tuplas
zipped = List.zip([[1, 2, 3], [:a, :b, :c]])
IO.inspect(zipped, label: "List.zip")

# List.delete - elimina PRIMERA ocurrencia
IO.inspect(List.delete([1, 2, 2, 3], 2), label: "List.delete (primera ocurrencia)")

# List.insert_at
IO.inspect(List.insert_at([1, 2, 3], 1, :nuevo), label: "List.insert_at(lista, 1, :nuevo)")

# List.replace_at
IO.inspect(List.replace_at([1, 2, 3], 1, :reemplazo), label: "List.replace_at")

# List.update_at - actualiza con una funcion
IO.inspect(List.update_at([1, 2, 3], 1, fn x -> x * 10 end), label: "List.update_at con funcion")

# ==========================================
# FUNCIONES DEL MODULO Enum (muy usadas con listas)
# ==========================================

IO.puts("\n--- Funciones de Enum ---")

numeros = [1, 2, 3, 4, 5]

IO.inspect(Enum.map(numeros, fn x -> x * 2 end), label: "Enum.map")
IO.inspect(Enum.filter(numeros, fn x -> rem(x, 2) == 0 end), label: "Enum.filter (pares)")
IO.inspect(Enum.reduce(numeros, 0, fn x, acc -> x + acc end), label: "Enum.reduce (suma)")
IO.inspect(Enum.sum(numeros), label: "Enum.sum")
IO.inspect(Enum.count(numeros), label: "Enum.count")
IO.inspect(Enum.member?(numeros, 3), label: "Enum.member?(3)")
IO.inspect(Enum.at(numeros, 2), label: "Enum.at(2) - indice 2")
IO.inspect(Enum.reverse(numeros), label: "Enum.reverse")
IO.inspect(Enum.sort([3, 1, 4, 1, 5]), label: "Enum.sort")
IO.inspect(Enum.uniq([1, 2, 2, 3, 3, 3]), label: "Enum.uniq")
IO.inspect(Enum.take(numeros, 3), label: "Enum.take(3)")
IO.inspect(Enum.drop(numeros, 2), label: "Enum.drop(2)")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

# Head/Tail en lista vacia - CRASHEA!
# [h | t] = []  # MatchError!
IO.puts("CUIDADO: [h | t] = [] causa MatchError")

# Solucion: usar pattern matching con case
resultado = case [] do
  [h | _t] -> "Tiene head: #{h}"
  [] -> "Lista vacia"
end
IO.inspect(resultado, label: "Pattern matching seguro con lista vacia")

# List.first y List.last en lista vacia retornan nil
IO.inspect(List.first([]), label: "List.first([]) retorna")
IO.inspect(List.last([]), label: "List.last([]) retorna")

# Enum.at con indice fuera de rango retorna nil
IO.inspect(Enum.at([1, 2, 3], 100), label: "Enum.at indice fuera de rango")

# Enum.at con valor default
IO.inspect(Enum.at([1, 2, 3], 100, :no_existe), label: "Enum.at con default")

# Indices negativos en List.insert_at
IO.inspect(List.insert_at([1, 2, 3], -1, :final), label: "insert_at con indice -1 (final)")

# Charlists vs Strings
# Una lista de enteros que corresponden a ASCII se muestra como charlist
charlist = [104, 111, 108, 97]
IO.inspect(charlist, label: "Lista de ASCII (charlist)")
IO.inspect(charlist, charlists: :as_lists, label: "Forzar mostrar como lista")

# Para evitar confusion, mezclar con un numero no-ASCII
IO.inspect([104, 111, 108, 97, 0], label: "Con 0 se ve como lista")

# ==========================================
# PERFORMANCE CONSIDERATIONS
# ==========================================

IO.puts("\n--- CONSIDERACIONES DE PERFORMANCE ---")

# Prepend es O(1) - MUY RAPIDO
# [elemento | lista]

# Append es O(n) - LENTO para listas grandes
# lista ++ [elemento]

IO.puts("Prepend [x | lista] es O(1)")
IO.puts("Append lista ++ [x] es O(n)")
IO.puts("Acceso por indice Enum.at es O(n)")
IO.puts("Para acceso aleatorio frecuente, usar Map o Tuple")

# ==========================================
# COMPREHENSIONS (for)
# ==========================================

IO.puts("\n--- LIST COMPREHENSIONS ---")

# Generar lista con for
cuadrados = for x <- 1..5, do: x * x
IO.inspect(cuadrados, label: "Cuadrados con for")

# Con filtro
pares_cuadrados = for x <- 1..10, rem(x, 2) == 0, do: x * x
IO.inspect(pares_cuadrados, label: "Cuadrados de pares")

# Producto cartesiano
producto = for x <- [1, 2], y <- [:a, :b], do: {x, y}
IO.inspect(producto, label: "Producto cartesiano")
