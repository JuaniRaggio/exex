# ==========================================
# TUPLAS EN ELIXIR
# ==========================================
# Las tuplas almacenan elementos contiguos en memoria
# Acceso por indice es O(1) - MUY RAPIDO
# Pero modificar es O(n) porque hay que copiar toda la tupla
# Se usan mucho para retornar multiples valores
# Convencion: {:ok, valor} o {:error, razon}

# ==========================================
# CREACION BASICA
# ==========================================

tupla_vacia = {}
tupla_simple = {1, 2, 3}
tupla_mixta = {:ok, "exito", 42, true}
tupla_anidada = {{1, 2}, {3, 4}}

IO.inspect(tupla_vacia, label: "Tupla vacia")
IO.inspect(tupla_simple, label: "Tupla simple")
IO.inspect(tupla_mixta, label: "Tupla mixta")
IO.inspect(tupla_anidada, label: "Tupla anidada")

# ==========================================
# ACCESO A ELEMENTOS
# ==========================================

IO.puts("\n--- ACCESO A ELEMENTOS ---")

tupla = {:a, :b, :c, :d}

# elem/2 - acceso por indice (base 0)
IO.inspect(elem(tupla, 0), label: "elem(tupla, 0)")
IO.inspect(elem(tupla, 2), label: "elem(tupla, 2)")

# tuple_size/1 - obtener tamanio
IO.inspect(tuple_size(tupla), label: "tuple_size")

# ==========================================
# MODIFICACION (crea nueva tupla)
# ==========================================

IO.puts("\n--- MODIFICACION ---")

original = {:a, :b, :c}

# put_elem/3 - reemplaza elemento en indice
modificada = put_elem(original, 1, :NUEVA)
IO.inspect(original, label: "Original (no cambia)")
IO.inspect(modificada, label: "Modificada")

# ==========================================
# PATTERN MATCHING CON TUPLAS
# ==========================================

IO.puts("\n--- PATTERN MATCHING ---")

# Extraer valores
{status, mensaje, codigo} = {:ok, "Todo bien", 200}
IO.inspect(status, label: "status")
IO.inspect(mensaje, label: "mensaje")
IO.inspect(codigo, label: "codigo")

# Ignorar valores con _
{_, valor, _} = {:ignorado, "importante", :ignorado}
IO.inspect(valor, label: "Solo el valor del medio")

# Patron comun: resultado de funciones
resultado = {:ok, "datos"}

case resultado do
  {:ok, data} -> IO.puts("Exito: #{data}")
  {:error, reason} -> IO.puts("Error: #{reason}")
end

# Con guards
resultado_numero = {:ok, 42}

case resultado_numero do
  {:ok, n} when is_number(n) and n > 0 -> IO.puts("Numero positivo: #{n}")
  {:ok, n} when is_number(n) -> IO.puts("Numero: #{n}")
  {:ok, _} -> IO.puts("Ok pero no es numero")
  {:error, _} -> IO.puts("Error")
end

# ==========================================
# MODULO Tuple
# ==========================================

IO.puts("\n--- MODULO Tuple ---")

t = {:a, :b, :c}

# Tuple.append - agrega al final
IO.inspect(Tuple.append(t, :d), label: "Tuple.append")

# Tuple.insert_at - inserta en posicion
IO.inspect(Tuple.insert_at(t, 1, :nuevo), label: "Tuple.insert_at(1, :nuevo)")

# Tuple.delete_at - elimina en posicion
IO.inspect(Tuple.delete_at(t, 1), label: "Tuple.delete_at(1)")

# Tuple.duplicate - crear tupla con valor repetido
IO.inspect(Tuple.duplicate(:x, 5), label: "Tuple.duplicate(:x, 5)")

# Tuple.to_list - convertir a lista
IO.inspect(Tuple.to_list(t), label: "Tuple.to_list")

# List.to_tuple - convertir lista a tupla
IO.inspect(List.to_tuple([1, 2, 3]), label: "List.to_tuple")

# ==========================================
# USOS COMUNES
# ==========================================

IO.puts("\n--- USOS COMUNES ---")

# 1. Retorno de funciones con status
# Simulando File.read
resultado_archivo = {:ok, "contenido del archivo"}
# resultado_archivo = {:error, :enoent}

# 2. Coordenadas
punto = {10, 20}
{x, y} = punto
IO.inspect({x, y}, label: "Coordenadas")

# 3. RGB colors
color = {255, 128, 0}
{r, g, b} = color
IO.inspect("RGB: #{r}, #{g}, #{b}", label: "Color")

# 4. Registros simples (aunque para esto mejor usar structs)
persona = {"Juan", 30, :developer}
{nombre, edad, profesion} = persona
IO.puts("#{nombre} tiene #{edad} anios y es #{profesion}")

# 5. En pattern matching de funciones
defmodule Ejemplo do
  def procesar({:ok, valor}), do: "Exito: #{valor}"
  def procesar({:error, razon}), do: "Error: #{razon}"
  def procesar(_), do: "Formato desconocido"
end

IO.inspect(Ejemplo.procesar({:ok, "datos"}), label: "procesar ok")
IO.inspect(Ejemplo.procesar({:error, "fallo"}), label: "procesar error")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

# elem con indice fuera de rango - CRASHEA!
# elem({:a, :b}, 5)  # ArgumentError!
IO.puts("CUIDADO: elem con indice invalido causa ArgumentError")

# Solucion: verificar tamanio primero
tupla_test = {:a, :b}
indice = 5
if indice < tuple_size(tupla_test) do
  IO.inspect(elem(tupla_test, indice))
else
  IO.puts("Indice #{indice} fuera de rango")
end

# put_elem con indice fuera de rango - CRASHEA!
# put_elem({:a, :b}, 5, :x)  # ArgumentError!
IO.puts("CUIDADO: put_elem con indice invalido causa ArgumentError")

# Tupla vacia
IO.inspect(tuple_size({}), label: "Tamanio de tupla vacia")
# elem({}, 0)  # ArgumentError!

# Pattern matching con tamanio incorrecto - CRASHEA!
# {a, b} = {1, 2, 3}  # MatchError!
IO.puts("CUIDADO: {a, b} = {1, 2, 3} causa MatchError")

# Comparacion de tuplas
# Se comparan elemento por elemento
IO.inspect({1, 2} < {1, 3}, label: "{1, 2} < {1, 3}")
IO.inspect({1, 2} < {2, 1}, label: "{1, 2} < {2, 1}")
IO.inspect({1, 2, 3} > {1, 2}, label: "{1, 2, 3} > {1, 2}")

# ==========================================
# TUPLAS VS LISTAS
# ==========================================

IO.puts("\n--- TUPLAS VS LISTAS ---")

IO.puts("""
TUPLAS:
- Acceso por indice O(1)
- Modificacion O(n) (copia todo)
- Tamanio fijo conceptualmente
- Usadas para datos estructurados
- Retorno de funciones {:ok, valor}

LISTAS:
- Acceso por indice O(n)
- Prepend O(1)
- Tamanio variable
- Usadas para colecciones
- Procesamiento secuencial
""")

# Regla general:
# - Pocos elementos con significado posicional: TUPLA
# - Coleccion de elementos homogeneos: LISTA
