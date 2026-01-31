# ==========================================
# MAPSETS EN ELIXIR
# ==========================================
# MapSet es la implementacion de conjuntos (sets) en Elixir
# CARACTERISTICAS:
# - Elementos unicos (sin duplicados)
# - Sin orden garantizado
# - Acceso, insercion y verificacion son O(log n)
# - Basado en maps internamente
# - Ideal para verificar pertenencia y operaciones de conjuntos

# ==========================================
# CREACION
# ==========================================

# MapSet vacio
vacio = MapSet.new()
IO.inspect(vacio, label: "MapSet vacio")

# Desde una lista
desde_lista = MapSet.new([1, 2, 3, 4, 5])
IO.inspect(desde_lista, label: "Desde lista")

# Los duplicados se eliminan automaticamente!
con_duplicados = MapSet.new([1, 2, 2, 3, 3, 3, 4])
IO.inspect(con_duplicados, label: "Duplicados eliminados")

# Desde cualquier enumerable
desde_rango = MapSet.new(1..5)
IO.inspect(desde_rango, label: "Desde rango")

# Con transformacion
transformado = MapSet.new([1, 2, 3], fn x -> x * 2 end)
IO.inspect(transformado, label: "Con transformacion")

# Tipos mixtos (cualquier tipo de elemento)
mixto = MapSet.new([1, "dos", :tres, {4, 5}])
IO.inspect(mixto, label: "Tipos mixtos")

# ==========================================
# OPERACIONES BASICAS
# ==========================================

IO.puts("\n--- OPERACIONES BASICAS ---")

set = MapSet.new([1, 2, 3])

# MapSet.put/2 - agregar elemento
con_nuevo = MapSet.put(set, 4)
IO.inspect(con_nuevo, label: "put(4)")

# Si el elemento ya existe, no cambia nada
sin_cambio = MapSet.put(set, 2)
IO.inspect(sin_cambio, label: "put(2) - ya existe")

# MapSet.delete/2 - eliminar elemento
sin_dos = MapSet.delete(set, 2)
IO.inspect(sin_dos, label: "delete(2)")

# Eliminar elemento que no existe - no falla
sin_cambio2 = MapSet.delete(set, 99)
IO.inspect(sin_cambio2, label: "delete(99) - no existe")

# MapSet.size/1
IO.inspect(MapSet.size(set), label: "size")

# MapSet.member?/2 - verificar pertenencia (MUY RAPIDO)
IO.inspect(MapSet.member?(set, 2), label: "member?(2)")
IO.inspect(MapSet.member?(set, 99), label: "member?(99)")

# ==========================================
# OPERACIONES DE CONJUNTOS
# ==========================================

IO.puts("\n--- OPERACIONES DE CONJUNTOS ---")

a = MapSet.new([1, 2, 3, 4])
b = MapSet.new([3, 4, 5, 6])

# UNION - elementos en A o B (o ambos)
union = MapSet.union(a, b)
IO.inspect(union, label: "union(A, B)")

# INTERSECCION - elementos en A y B
interseccion = MapSet.intersection(a, b)
IO.inspect(interseccion, label: "intersection(A, B)")

# DIFERENCIA - elementos en A que NO estan en B
diferencia = MapSet.difference(a, b)
IO.inspect(diferencia, label: "difference(A, B) - en A pero no en B")

# Diferencia inversa
diferencia_inv = MapSet.difference(b, a)
IO.inspect(diferencia_inv, label: "difference(B, A) - en B pero no en A")

# DIFERENCIA SIMETRICA - elementos en A o B pero NO en ambos
# No hay funcion directa, pero se puede calcular:
simetrica = MapSet.union(
  MapSet.difference(a, b),
  MapSet.difference(b, a)
)
IO.inspect(simetrica, label: "diferencia simetrica")

# ==========================================
# COMPARACIONES DE CONJUNTOS
# ==========================================

IO.puts("\n--- COMPARACIONES ---")

pequenio = MapSet.new([1, 2])
grande = MapSet.new([1, 2, 3, 4])
otro = MapSet.new([3, 4])

# MapSet.subset?/2 - es subconjunto?
IO.inspect(MapSet.subset?(pequenio, grande), label: "subset?({1,2}, {1,2,3,4})")
IO.inspect(MapSet.subset?(grande, pequenio), label: "subset?({1,2,3,4}, {1,2})")

# Igualdad
igual1 = MapSet.new([1, 2, 3])
igual2 = MapSet.new([3, 1, 2])  # diferente orden, mismo contenido
IO.inspect(MapSet.equal?(igual1, igual2), label: "equal? (orden no importa)")
IO.inspect(igual1 == igual2, label: "== tambien funciona")

# MapSet.disjoint?/2 - no tienen elementos en comun?
IO.inspect(MapSet.disjoint?(pequenio, otro), label: "disjoint?({1,2}, {3,4})")
IO.inspect(MapSet.disjoint?(pequenio, grande), label: "disjoint?({1,2}, {1,2,3,4})")

# ==========================================
# ITERACION
# ==========================================

IO.puts("\n--- ITERACION ---")

numeros = MapSet.new([10, 20, 30, 40])

# Enum.each
IO.puts("Recorriendo con Enum.each:")
Enum.each(numeros, fn x -> IO.puts("  - #{x}") end)

# Enum.map (retorna LISTA, no MapSet!)
lista = Enum.map(numeros, fn x -> x * 2 end)
IO.inspect(lista, label: "Enum.map retorna LISTA")

# Para obtener MapSet, usar MapSet.new
set_doble = MapSet.new(numeros, fn x -> x * 2 end)
IO.inspect(set_doble, label: "MapSet.new con funcion")

# Enum.filter
filtrado = Enum.filter(numeros, fn x -> x > 15 end)
IO.inspect(filtrado, label: "Enum.filter (lista)")
IO.inspect(MapSet.new(filtrado), label: "Convertido a MapSet")

# Enum.reduce
suma = Enum.reduce(numeros, 0, fn x, acc -> x + acc end)
IO.inspect(suma, label: "Suma con reduce")

# Enum.to_list
como_lista = Enum.to_list(numeros)
IO.inspect(como_lista, label: "to_list")

# ==========================================
# CASOS DE USO PRACTICOS
# ==========================================

IO.puts("\n--- CASOS DE USO ---")

# 1. Eliminar duplicados de una lista
lista_con_dups = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
sin_dups = lista_con_dups |> MapSet.new() |> Enum.to_list()
IO.inspect(sin_dups, label: "Lista sin duplicados")

# 2. Verificar permisos
permisos_usuario = MapSet.new([:leer, :escribir])
permisos_requeridos = MapSet.new([:leer, :ejecutar])

tiene_todos? = MapSet.subset?(permisos_requeridos, permisos_usuario)
IO.inspect(tiene_todos?, label: "Tiene todos los permisos?")

permisos_faltantes = MapSet.difference(permisos_requeridos, permisos_usuario)
IO.inspect(permisos_faltantes, label: "Permisos faltantes")

# 3. Tags/Etiquetas unicas
tags_articulo1 = MapSet.new([:elixir, :programacion, :funcional])
tags_articulo2 = MapSet.new([:elixir, :otp, :concurrencia])

tags_comunes = MapSet.intersection(tags_articulo1, tags_articulo2)
IO.inspect(tags_comunes, label: "Tags en comun")

todos_tags = MapSet.union(tags_articulo1, tags_articulo2)
IO.inspect(todos_tags, label: "Todos los tags")

# 4. Visitantes unicos
visitas = ["juan", "ana", "juan", "pedro", "ana", "juan"]
visitantes_unicos = MapSet.new(visitas)
IO.inspect(MapSet.size(visitantes_unicos), label: "Cantidad de visitantes unicos")

# 5. Verificacion rapida de existencia
palabras_prohibidas = MapSet.new(["spam", "gratis", "urgente"])
mensaje = "Este es un mensaje urgente"

contiene_prohibida? = mensaje
  |> String.downcase()
  |> String.split()
  |> Enum.any?(fn palabra -> MapSet.member?(palabras_prohibidas, palabra) end)

IO.inspect(contiene_prohibida?, label: "Contiene palabra prohibida?")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

# MapSet vacio
vacio = MapSet.new()
IO.inspect(MapSet.size(vacio), label: "Size de vacio")
IO.inspect(MapSet.member?(vacio, :algo), label: "member? en vacio")

# Union con vacio
set = MapSet.new([1, 2])
IO.inspect(MapSet.union(set, vacio) == set, label: "union con vacio = original")

# Interseccion con vacio
IO.inspect(MapSet.intersection(set, vacio), label: "intersection con vacio")

# Elementos nil (valido)
con_nil = MapSet.new([1, nil, 2])
IO.inspect(con_nil, label: "MapSet con nil")
IO.inspect(MapSet.member?(con_nil, nil), label: "member?(nil)")

# Comparacion de tipos diferentes
# MapSet compara por igualdad estricta (===)
numeros_int = MapSet.new([1, 2, 3])
numeros_float = MapSet.new([1.0, 2.0, 3.0])
IO.inspect(MapSet.equal?(numeros_int, numeros_float), label: "1 == 1.0 en MapSet?")

# CUIDADO: 1 y 1.0 son considerados diferentes!
mixto = MapSet.new([1, 1.0])
IO.inspect(MapSet.size(mixto), label: "Size de {1, 1.0}")

# MapSet de MapSets (anidado)
inner1 = MapSet.new([1, 2])
inner2 = MapSet.new([3, 4])
outer = MapSet.new([inner1, inner2])
IO.inspect(outer, label: "MapSet de MapSets")
IO.inspect(MapSet.member?(outer, inner1), label: "Contiene inner1?")

# ==========================================
# PERFORMANCE
# ==========================================

IO.puts("\n--- PERFORMANCE ---")

IO.puts("""
MapSet PERFORMANCE:
- member?/2: O(log n) - MUY rapido
- put/2: O(log n)
- delete/2: O(log n)
- union/2: O(m log(m + n)) donde m <= n
- intersection/2: O(m log(m + n)) donde m <= n
- difference/2: O(m log n)

COMPARADO CON LISTAS:
- Verificar pertenencia en lista: O(n)
- Verificar pertenencia en MapSet: O(log n)

CUANDO USAR MapSet:
- Necesitas verificar pertenencia frecuentemente
- Necesitas garantizar unicidad
- Necesitas operaciones de conjuntos
- El orden no importa

CUANDO USAR LISTAS:
- Necesitas mantener el orden
- Necesitas duplicados
- Solo recorres secuencialmente
""")

# Ejemplo de porque MapSet es mejor para pertenencia:
# En una lista de 1000 elementos, buscar si existe uno es O(1000)
# En un MapSet de 1000 elementos, buscar es O(log 1000) = O(10)

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n--- RESUMEN ---")

IO.puts("""
MapSet:
- MapSet.new/0, new/1, new/2: crear
- MapSet.put/2: agregar elemento
- MapSet.delete/2: eliminar elemento
- MapSet.member?/2: verificar pertenencia
- MapSet.size/1: cantidad de elementos
- MapSet.union/2: union de conjuntos
- MapSet.intersection/2: interseccion
- MapSet.difference/2: diferencia (A - B)
- MapSet.subset?/2: es subconjunto?
- MapSet.disjoint?/2: no tienen elementos comunes?
- MapSet.equal?/2: son iguales?

FUNCIONES DE Enum FUNCIONAN:
- Enum.map, filter, reduce, each, to_list, etc.
- PERO: Enum.map retorna lista, no MapSet!
""")
