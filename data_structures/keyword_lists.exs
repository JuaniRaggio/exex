# ==========================================
# KEYWORD LISTS EN ELIXIR
# ==========================================
# Son listas de tuplas de 2 elementos donde el primer
# elemento es un atom. Tienen una sintaxis especial.
#
# CARACTERISTICAS CLAVE:
# - Mantienen el orden de insercion
# - Permiten claves duplicadas
# - Son una LISTA, no un map
# - Acceso es O(n), no O(1)
# - Muy usadas para opciones de funciones

# ==========================================
# CREACION BASICA
# ==========================================

# Estas dos formas son IDENTICAS:
kw1 = [{:nombre, "Juan"}, {:edad, 30}]
kw2 = [nombre: "Juan", edad: 30]

IO.inspect(kw1, label: "Forma explicita")
IO.inspect(kw2, label: "Forma sintaxis especial")
IO.inspect(kw1 == kw2, label: "Son iguales?")

# Verificar que ES una lista
IO.inspect(is_list(kw2), label: "Es una lista?")

# Keyword list vacia
vacia = []
IO.inspect(vacia, label: "Keyword list vacia")

# ==========================================
# ACCESO A VALORES
# ==========================================

IO.puts("\n--- ACCESO A VALORES ---")

opts = [puerto: 8080, host: "localhost", timeout: 5000]

# Sintaxis corchetes (retorna primer match o nil)
IO.inspect(opts[:puerto], label: "opts[:puerto]")
IO.inspect(opts[:inexistente], label: "opts[:inexistente]")

# Keyword.get/2 y Keyword.get/3
IO.inspect(Keyword.get(opts, :host), label: "Keyword.get")
IO.inspect(Keyword.get(opts, :no_existe, "default"), label: "Keyword.get con default")

# Keyword.fetch/2 y Keyword.fetch!/2
IO.inspect(Keyword.fetch(opts, :puerto), label: "Keyword.fetch (retorna :ok tuple)")
IO.inspect(Keyword.fetch(opts, :no_existe), label: "Keyword.fetch inexistente")
# Keyword.fetch!(opts, :no_existe)  # KeyError!

# ==========================================
# CLAVES DUPLICADAS (diferencia clave con Maps!)
# ==========================================

IO.puts("\n--- CLAVES DUPLICADAS ---")

# Los keyword lists PERMITEN claves duplicadas
duplicadas = [a: 1, b: 2, a: 3, a: 4]
IO.inspect(duplicadas, label: "Con claves duplicadas")

# El acceso [] retorna el PRIMER valor
IO.inspect(duplicadas[:a], label: "duplicadas[:a] (primer match)")

# Keyword.get_values/2 - obtener TODOS los valores
IO.inspect(Keyword.get_values(duplicadas, :a), label: "Keyword.get_values(:a)")

# Esto es util en algunos casos especificos
# Ejemplo: multiples headers HTTP con mismo nombre
headers = ["content-type": "application/json", "accept": "text/html", "accept": "application/json"]
IO.inspect(Keyword.get_values(headers, :accept), label: "Todos los accept")

# ==========================================
# ORDEN PRESERVADO
# ==========================================

IO.puts("\n--- ORDEN PRESERVADO ---")

# El orden de insercion se mantiene siempre
ordenado = [z: 1, a: 2, m: 3]
IO.inspect(Keyword.keys(ordenado), label: "Claves en orden de insercion")

# A diferencia de Maps pequeños que tambien preservan orden,
# esto es GARANTIZADO en keyword lists

# ==========================================
# MODIFICACION
# ==========================================

IO.puts("\n--- MODIFICACION ---")

original = [a: 1, b: 2, c: 3]

# Keyword.put/3 - reemplaza o agrega
modificado = Keyword.put(original, :b, 99)
IO.inspect(modificado, label: "Keyword.put reemplaza :b")

# Si hay duplicados, put remueve TODOS y pone el nuevo al final
con_dups = [a: 1, a: 2, a: 3]
puesto = Keyword.put(con_dups, :a, 100)
IO.inspect(puesto, label: "put en duplicados (remueve todos)")

# Keyword.put_new/3 - solo agrega si NO existe
nuevo = Keyword.put_new(original, :d, 4)
existente = Keyword.put_new(original, :a, 999)
IO.inspect(nuevo, label: "put_new con clave nueva")
IO.inspect(existente, label: "put_new con clave existente (no cambia)")

# Keyword.merge/2
extra = [c: 99, d: 4]
merged = Keyword.merge(original, extra)
IO.inspect(merged, label: "Keyword.merge")

# Keyword.update/4
actualizado = Keyword.update(original, :a, 0, fn v -> v * 10 end)
IO.inspect(actualizado, label: "Keyword.update")

# ==========================================
# ELIMINACION
# ==========================================

IO.puts("\n--- ELIMINACION ---")

datos = [x: 1, y: 2, z: 3, y: 4]

# Keyword.delete/2 - elimina TODAS las ocurrencias de la clave
sin_y = Keyword.delete(datos, :y)
IO.inspect(sin_y, label: "delete :y (elimina TODAS)")

# Keyword.delete_first/2 - elimina solo la primera
sin_primera_y = Keyword.delete_first(datos, :y)
IO.inspect(sin_primera_y, label: "delete_first :y")

# Keyword.drop/2
sin_varias = Keyword.drop(datos, [:x, :z])
IO.inspect(sin_varias, label: "drop [:x, :z]")

# Keyword.pop/2
{valor, resto} = Keyword.pop(datos, :x)
IO.inspect(valor, label: "valor popeado")
IO.inspect(resto, label: "resto despues de pop")

# Keyword.pop_first/2 vs pop (con duplicados)
dup = [a: 1, a: 2]
{v1, r1} = Keyword.pop_first(dup, :a)
IO.inspect({v1, r1}, label: "pop_first con duplicados")

# ==========================================
# FUNCIONES UTILES
# ==========================================

IO.puts("\n--- FUNCIONES UTILES ---")

kw = [uno: 1, dos: 2, tres: 3]

# Keyword.keys/1 y Keyword.values/1
IO.inspect(Keyword.keys(kw), label: "Keyword.keys")
IO.inspect(Keyword.values(kw), label: "Keyword.values")

# Keyword.has_key?/2
IO.inspect(Keyword.has_key?(kw, :uno), label: "has_key?(:uno)")
IO.inspect(Keyword.has_key?(kw, :cuatro), label: "has_key?(:cuatro)")

# Keyword.take/2
IO.inspect(Keyword.take(kw, [:uno, :tres]), label: "take [:uno, :tres]")

# Keyword.keyword?/1 - verificar si es keyword list valida
IO.inspect(Keyword.keyword?([a: 1, b: 2]), label: "keyword?([a: 1, b: 2])")
IO.inspect(Keyword.keyword?([{:a, 1}, {"b", 2}]), label: "keyword? con string key")
IO.inspect(Keyword.keyword?([1, 2, 3]), label: "keyword?([1, 2, 3])")

# Keyword.new/1 - crear desde enumerable
desde_map = Keyword.new(%{a: 1, b: 2})
IO.inspect(desde_map, label: "Keyword.new desde map")

# ==========================================
# USO EN FUNCIONES (muy comun!)
# ==========================================

IO.puts("\n--- USO EN FUNCIONES ---")

# Los keyword lists son perfectos para opciones opcionales
defmodule MiModulo do
  def saludar(nombre, opts \\ []) do
    # Extraer opciones con defaults
    mayusculas = Keyword.get(opts, :mayusculas, false)
    prefijo = Keyword.get(opts, :prefijo, "Hola")

    mensaje = "#{prefijo}, #{nombre}!"

    if mayusculas do
      String.upcase(mensaje)
    else
      mensaje
    end
  end

  # Cuando el keyword list es el ultimo argumento,
  # los corchetes son opcionales!
  def ejemplo do
    # Estas llamadas son IDENTICAS:
    saludar("Juan", [mayusculas: true, prefijo: "Hey"])
    saludar("Juan", mayusculas: true, prefijo: "Hey")  # Sin corchetes!
  end
end

IO.inspect(MiModulo.saludar("Juan"), label: "Sin opciones")
IO.inspect(MiModulo.saludar("Juan", mayusculas: true), label: "Con mayusculas")
IO.inspect(MiModulo.saludar("Juan", prefijo: "Che"), label: "Con prefijo")
IO.inspect(MiModulo.saludar("Juan", mayusculas: true, prefijo: "Ey"), label: "Ambas")

# Este patron se usa MUCHO en Elixir
# Ejemplos reales:
# Enum.sort(lista, desc: true)
# String.split(str, trim: true)
# IO.inspect(valor, label: "algo")

# ==========================================
# PATTERN MATCHING
# ==========================================

IO.puts("\n--- PATTERN MATCHING ---")

config = [debug: true, port: 3000, env: :prod]

# Match en el primer elemento
[{clave, valor} | _resto] = config
IO.inspect({clave, valor}, label: "Primer elemento")

# Match especifico (solo funciona si esta en esa posicion!)
[debug: d | _] = config
IO.inspect(d, label: "debug (primer elemento)")

# CUIDADO: esto falla si el orden es diferente
# [port: p | _] = config  # MatchError! (port no es primero)

# Para acceder sin importar orden, usar Keyword.get
# o pattern matching en funcion:

defmodule Config do
  def procesar(opts) when is_list(opts) do
    # Extraer con defaults
    debug = Keyword.get(opts, :debug, false)
    port = Keyword.get(opts, :port, 8080)

    {debug, port}
  end
end

IO.inspect(Config.procesar(port: 9000), label: "Solo port")
IO.inspect(Config.procesar(debug: true), label: "Solo debug")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

# NO es keyword list si la clave no es atom
no_es_kw = [{"string", 1}, {123, 2}]
IO.inspect(Keyword.keyword?(no_es_kw), label: "Es keyword con claves no-atom?")

# NO es keyword list si las tuplas no son de 2 elementos
no_es_kw2 = [{:a, 1, "extra"}]
IO.inspect(Keyword.keyword?(no_es_kw2), label: "Es keyword con tuplas de 3?")

# Acceso con [] en lista normal retorna nil, no crashea
lista_normal = [1, 2, 3]
IO.inspect(lista_normal[:algo], label: "[:algo] en lista normal")

# Pero las funciones de Keyword si requieren keyword list valida
# Keyword.get([1, 2, 3], :a)  # ArgumentError!
IO.puts("CUIDADO: Keyword.get en lista normal causa ArgumentError")

# Keyword list vacia es valida
IO.inspect(Keyword.keyword?([]), label: "Lista vacia es keyword?")

# nil como valor (valido)
con_nil = [clave: nil]
IO.inspect(con_nil[:clave], label: "nil como valor")
IO.inspect(Keyword.has_key?(con_nil, :clave), label: "has_key? de clave con nil")

# ==========================================
# KEYWORD LIST VS MAP
# ==========================================

IO.puts("\n--- KEYWORD LIST VS MAP ---")

IO.puts("""
KEYWORD LIST:
- Es una LISTA de tuplas
- Permite claves duplicadas
- Mantiene orden de insercion
- Acceso O(n)
- Usada para opciones de funciones
- Sintaxis [clave: valor]

MAP:
- Es una estructura dedicada
- Claves unicas
- Orden: preservado en Maps pequenios
- Acceso O(log n)
- Usada para datos estructurados
- Sintaxis %{clave: valor}

CUANDO USAR CADA UNA:
- Opciones de funciones: KEYWORD LIST
- Datos de dominio: MAP
- Necesitas duplicados: KEYWORD LIST
- Necesitas acceso rapido: MAP
- Datos vienen de JSON/DB: MAP
""")

# Conversion entre ellos
kw_original = [a: 1, b: 2]
mapa = Map.new(kw_original)
IO.inspect(mapa, label: "Keyword a Map")

kw_desde_map = Keyword.new(%{x: 10, y: 20})
IO.inspect(kw_desde_map, label: "Map a Keyword")
