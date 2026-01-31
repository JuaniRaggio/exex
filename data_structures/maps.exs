# ==========================================
# MAPS EN ELIXIR
# ==========================================
# Los Maps son LA estructura clave-valor en Elixir
# Las claves pueden ser de cualquier tipo
# Acceso, insercion y actualizacion son O(log n)
# Son la estructura mas versatil para datos estructurados

# ==========================================
# CREACION BASICA
# ==========================================

# Map vacio
mapa_vacio = %{}

# Con claves atom (sintaxis especial, mas comun)
persona = %{nombre: "Juan", edad: 30, activo: true}

# Con claves de cualquier tipo (sintaxis general)
mapa_general = %{"string_key" => 1, :atom_key => 2, 123 => "numero como clave"}

# Mezclando (aunque no es comun)
mezclado = %{:atomo => 1, "string" => 2}

IO.inspect(mapa_vacio, label: "Map vacio")
IO.inspect(persona, label: "Map con claves atom")
IO.inspect(mapa_general, label: "Map con claves variadas")

# ==========================================
# SINTAXIS: => vs :
# ==========================================

IO.puts("\n--- SINTAXIS => vs : ---")

# Estas dos formas son EQUIVALENTES para claves atom:
mapa_a = %{:nombre => "Ana", :edad => 25}
mapa_b = %{nombre: "Ana", edad: 25}

IO.inspect(mapa_a == mapa_b, label: "Son iguales?")

# IMPORTANTE: La sintaxis : solo funciona con atoms!
# %{1: "uno"}  # SyntaxError!
# %{"key": "val"}  # SyntaxError!

IO.puts("La sintaxis clave: valor SOLO funciona con atoms")

# ==========================================
# ACCESO A VALORES
# ==========================================

IO.puts("\n--- ACCESO A VALORES ---")

usuario = %{nombre: "Carlos", edad: 28, email: "carlos@mail.com"}

# 1. Sintaxis punto (SOLO para claves atom que EXISTEN)
IO.inspect(usuario.nombre, label: "usuario.nombre")
IO.inspect(usuario.edad, label: "usuario.edad")

# 2. Sintaxis corchetes (cualquier tipo de clave)
IO.inspect(usuario[:nombre], label: "usuario[:nombre]")
IO.inspect(usuario[:edad], label: "usuario[:edad]")

# 3. Map.get/2 y Map.get/3 (con valor default)
IO.inspect(Map.get(usuario, :nombre), label: "Map.get(:nombre)")
IO.inspect(Map.get(usuario, :inexistente), label: "Map.get clave inexistente")
IO.inspect(Map.get(usuario, :inexistente, "default"), label: "Map.get con default")

# 4. Map.fetch/2 y Map.fetch!/2
IO.inspect(Map.fetch(usuario, :nombre), label: "Map.fetch (retorna {:ok, val})")
IO.inspect(Map.fetch(usuario, :inexistente), label: "Map.fetch clave inexistente")
# Map.fetch!(usuario, :inexistente)  # KeyError!

# ==========================================
# DIFERENCIA CRUCIAL: . vs []
# ==========================================

IO.puts("\n--- DIFERENCIA . vs [] ---")

mapa = %{clave: "valor"}

# Con [] - clave inexistente retorna nil
IO.inspect(mapa[:inexistente], label: "mapa[:inexistente]")

# Con . - clave inexistente CRASHEA!
# mapa.inexistente  # KeyError!
IO.puts("CUIDADO: mapa.clave_inexistente causa KeyError")

# Regla: usa . cuando SABES que la clave existe
#        usa [] cuando la clave puede no existir

# ==========================================
# AGREGAR Y ACTUALIZAR
# ==========================================

IO.puts("\n--- AGREGAR Y ACTUALIZAR ---")

original = %{a: 1, b: 2}

# Map.put/3 - agrega o actualiza
con_nueva = Map.put(original, :c, 3)
actualizado = Map.put(original, :a, 100)
IO.inspect(con_nueva, label: "Map.put nueva clave")
IO.inspect(actualizado, label: "Map.put actualiza existente")
IO.inspect(original, label: "Original no cambia")

# Sintaxis de actualizacion | (SOLO actualiza, no agrega)
actualizado2 = %{original | a: 999}
IO.inspect(actualizado2, label: "Sintaxis | actualiza")

# CUIDADO: | con clave inexistente CRASHEA!
# %{original | nueva: 1}  # KeyError!
IO.puts("CUIDADO: %{mapa | clave_nueva: val} causa KeyError")

# Map.merge/2 - combina dos maps
extra = %{c: 3, d: 4}
merged = Map.merge(original, extra)
IO.inspect(merged, label: "Map.merge")

# En conflicto, el segundo map gana
conflicto = Map.merge(%{a: 1, b: 2}, %{b: 99, c: 3})
IO.inspect(conflicto, label: "Merge con conflicto (segundo gana)")

# ==========================================
# ELIMINAR
# ==========================================

IO.puts("\n--- ELIMINAR ---")

datos = %{x: 1, y: 2, z: 3}

# Map.delete/2
sin_y = Map.delete(datos, :y)
IO.inspect(sin_y, label: "Map.delete(:y)")

# Map.drop/2 - eliminar multiples claves
sin_varias = Map.drop(datos, [:x, :z])
IO.inspect(sin_varias, label: "Map.drop([:x, :z])")

# Map.pop/2 - elimina y retorna valor
{valor, resto} = Map.pop(datos, :y)
IO.inspect(valor, label: "Valor extraido con pop")
IO.inspect(resto, label: "Map restante")

# pop con clave inexistente retorna {nil, mapa_original}
{val, _} = Map.pop(datos, :inexistente)
IO.inspect(val, label: "pop de inexistente")

# ==========================================
# OTRAS FUNCIONES UTILES
# ==========================================

IO.puts("\n--- FUNCIONES UTILES ---")

mapa = %{a: 1, b: 2, c: 3}

# Map.keys/1 y Map.values/1
IO.inspect(Map.keys(mapa), label: "Map.keys")
IO.inspect(Map.values(mapa), label: "Map.values")

# Map.has_key?/2
IO.inspect(Map.has_key?(mapa, :a), label: "has_key?(:a)")
IO.inspect(Map.has_key?(mapa, :z), label: "has_key?(:z)")

# Map.take/2 - obtener solo algunas claves
IO.inspect(Map.take(mapa, [:a, :c]), label: "Map.take([:a, :c])")

# Map.update/4 - actualizar con funcion
actualizado = Map.update(mapa, :a, 0, fn val -> val * 10 end)
IO.inspect(actualizado, label: "Map.update multiplica :a por 10")

# Map.update con clave inexistente usa el default
con_default = Map.update(mapa, :z, 100, fn val -> val * 10 end)
IO.inspect(con_default, label: "Map.update con default")

# Map.update!/3 - sin default, CRASHEA si no existe
# Map.update!(mapa, :z, fn v -> v end)  # KeyError!

# map_size/1
IO.inspect(map_size(mapa), label: "map_size")

# ==========================================
# PATTERN MATCHING
# ==========================================

IO.puts("\n--- PATTERN MATCHING ---")

usuario = %{nombre: "Ana", edad: 25, ciudad: "Buenos Aires"}

# Extraer valores especificos
%{nombre: n, edad: e} = usuario
IO.inspect({n, e}, label: "Extraidos nombre y edad")

# NO necesitas matchear todo el map!
%{ciudad: c} = usuario
IO.inspect(c, label: "Solo ciudad")

# Matchear valor especifico
case usuario do
  %{edad: e} when e >= 18 -> IO.puts("Es mayor de edad")
  %{edad: _} -> IO.puts("Es menor de edad")
end

# Matchear clave con variable
clave = :nombre
# %{^clave => valor} = usuario  # Usa pin operator
%{nombre: valor} = usuario
IO.inspect(valor, label: "Valor de nombre")

# Match falla si la clave no existe
# %{inexistente: x} = usuario  # MatchError!

# Pero el map puede tener MAS claves
%{nombre: n2} = %{nombre: "X", extra: "Y", otra: "Z"}
IO.inspect(n2, label: "Match parcial funciona")

# ==========================================
# ITERACION CON Enum
# ==========================================

IO.puts("\n--- ITERACION ---")

scores = %{juan: 100, maria: 95, pedro: 88}

# Enum.each
IO.puts("Recorriendo con Enum.each:")
Enum.each(scores, fn {nombre, puntaje} ->
  IO.puts("  #{nombre}: #{puntaje}")
end)

# Enum.map (retorna lista!)
lista = Enum.map(scores, fn {nombre, puntaje} -> {nombre, puntaje + 10} end)
IO.inspect(lista, label: "Enum.map retorna LISTA")

# Para obtener map, usar Map.new
mapa_nuevo = Map.new(scores, fn {k, v} -> {k, v + 10} end)
IO.inspect(mapa_nuevo, label: "Map.new para mantener map")

# Enum.filter (tambien retorna lista)
aprobados = Enum.filter(scores, fn {_nombre, puntaje} -> puntaje >= 90 end)
IO.inspect(aprobados, label: "Filtrados (lista de tuplas)")

# Convertir lista de tuplas a map
aprobados_map = Map.new(aprobados)
IO.inspect(aprobados_map, label: "Convertido a map")

# Enum.reduce
suma = Enum.reduce(scores, 0, fn {_k, v}, acc -> v + acc end)
IO.inspect(suma, label: "Suma de puntajes")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

# Claves duplicadas - la ultima gana
duplicado = %{a: 1, a: 2, a: 3}
IO.inspect(duplicado, label: "Claves duplicadas (ultima gana)")

# nil como clave (valido pero raro)
con_nil = %{nil => "valor para nil"}
IO.inspect(con_nil[nil], label: "nil como clave")

# nil como valor (comun)
con_nil_val = %{clave: nil}
IO.inspect(con_nil_val[:clave], label: "nil como valor")
IO.inspect(con_nil_val[:inexistente], label: "clave inexistente")
# Ambos retornan nil! Usa Map.has_key? para distinguir

# Distinguir nil-valor de clave-inexistente
IO.inspect(Map.has_key?(con_nil_val, :clave), label: "has_key? :clave (existe con nil)")
IO.inspect(Map.has_key?(con_nil_val, :otra), label: "has_key? :otra (no existe)")

# Maps son comparados por contenido
IO.inspect(%{a: 1, b: 2} == %{b: 2, a: 1}, label: "Orden no importa en ==")

# Pero el orden SI importa al iterar (orden de insercion)
mapa_ordenado = %{}
mapa_ordenado = Map.put(mapa_ordenado, :z, 1)
mapa_ordenado = Map.put(mapa_ordenado, :a, 2)
mapa_ordenado = Map.put(mapa_ordenado, :m, 3)
IO.inspect(Map.keys(mapa_ordenado), label: "Orden de insercion preservado")

# ==========================================
# MAPS ANIDADOS
# ==========================================

IO.puts("\n--- MAPS ANIDADOS ---")

datos = %{
  usuario: %{
    nombre: "Juan",
    direccion: %{
      ciudad: "Cordoba",
      pais: "Argentina"
    }
  }
}

# Acceso anidado
IO.inspect(datos.usuario.nombre, label: "Acceso anidado con .")
IO.inspect(datos[:usuario][:direccion][:ciudad], label: "Acceso anidado con []")

# get_in - acceso seguro a maps anidados
IO.inspect(get_in(datos, [:usuario, :nombre]), label: "get_in")
IO.inspect(get_in(datos, [:usuario, :inexistente, :otro]), label: "get_in con ruta invalida")

# put_in - actualizar anidado
actualizado = put_in(datos, [:usuario, :direccion, :ciudad], "Buenos Aires")
IO.inspect(actualizado.usuario.direccion.ciudad, label: "Despues de put_in")

# update_in - actualizar con funcion
modificado = update_in(datos, [:usuario, :nombre], fn n -> String.upcase(n) end)
IO.inspect(modificado.usuario.nombre, label: "Despues de update_in")
