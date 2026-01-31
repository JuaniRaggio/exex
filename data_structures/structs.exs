# ==========================================
# STRUCTS EN ELIXIR
# ==========================================
# Los Structs son Maps con caracteristicas especiales:
# - Tienen un conjunto FIJO de claves (definidas en compilacion)
# - Pueden tener valores default
# - Tienen el nombre del modulo asociado
# - Permiten pattern matching por tipo
# - Son la forma idiomatica de definir "tipos" en Elixir

# ==========================================
# DEFINICION BASICA
# ==========================================

# Los structs SIEMPRE se definen dentro de un modulo
defmodule Usuario do
  # defstruct define las claves permitidas
  defstruct [:nombre, :email, :edad]
end

# Crear un struct
usuario1 = %Usuario{nombre: "Juan", email: "juan@mail.com", edad: 30}
IO.inspect(usuario1, label: "Usuario creado")

# Claves no especificadas son nil
usuario2 = %Usuario{nombre: "Ana"}
IO.inspect(usuario2, label: "Usuario con campos nil")

# ==========================================
# VALORES DEFAULT
# ==========================================

IO.puts("\n--- VALORES DEFAULT ---")

defmodule Configuracion do
  defstruct puerto: 8080,
            host: "localhost",
            debug: false,
            timeout: 5000
end

# Al crear, usa los defaults
config1 = %Configuracion{}
IO.inspect(config1, label: "Con todos los defaults")

# Sobreescribir algunos defaults
config2 = %Configuracion{puerto: 3000, debug: true}
IO.inspect(config2, label: "Sobreescribiendo algunos")

# ==========================================
# MEZCLA DE DEFAULTS Y REQUERIDOS
# ==========================================

IO.puts("\n--- CAMPOS REQUERIDOS Y OPCIONALES ---")

defmodule Producto do
  # Los campos sin valor son nil por default
  # Los campos con valor tienen ese default
  defstruct nombre: nil,      # requerido conceptualmente
            precio: 0.0,      # default 0.0
            stock: 0,         # default 0
            activo: true      # default true
end

producto = %Producto{nombre: "Laptop", precio: 999.99}
IO.inspect(producto, label: "Producto")

# ==========================================
# @enforce_keys - CAMPOS REQUERIDOS
# ==========================================

IO.puts("\n--- @enforce_keys ---")

defmodule Orden do
  # Estos campos SON OBLIGATORIOS al crear el struct
  @enforce_keys [:id, :usuario_id]

  defstruct [:id, :usuario_id, :items, :total, estado: :pendiente]
end

# Esto funciona
orden = %Orden{id: 1, usuario_id: 100, items: [], total: 0}
IO.inspect(orden, label: "Orden valida")

# Esto CRASHEA:
# %Orden{items: []}  # ArgumentError: :id and :usuario_id are required
IO.puts("CUIDADO: Omitir @enforce_keys causa ArgumentError")

# ==========================================
# ACCESO A CAMPOS
# ==========================================

IO.puts("\n--- ACCESO A CAMPOS ---")

defmodule Persona do
  defstruct [:nombre, :edad, ciudad: "Buenos Aires"]
end

persona = %Persona{nombre: "Carlos", edad: 28}

# Sintaxis punto (recomendada para structs)
IO.inspect(persona.nombre, label: "persona.nombre")
IO.inspect(persona.ciudad, label: "persona.ciudad")

# Sintaxis corchetes (tambien funciona)
IO.inspect(persona[:edad], label: "persona[:edad]")

# Map.get tambien funciona (structs SON maps)
IO.inspect(Map.get(persona, :nombre), label: "Map.get")

# DIFERENCIA con maps: campo inexistente con . es error de compilacion!
# persona.campo_inexistente  # CompileError!
IO.puts("Ventaja: persona.campo_inexistente da error en COMPILACION")

# ==========================================
# ACTUALIZACION
# ==========================================

IO.puts("\n--- ACTUALIZACION ---")

original = %Persona{nombre: "Ana", edad: 25}

# Sintaxis de actualizacion (como maps)
actualizada = %Persona{original | edad: 26}
IO.inspect(actualizada, label: "Edad actualizada")

# Actualizar multiples campos
modificada = %Persona{original | nombre: "Ana Maria", ciudad: "Cordoba"}
IO.inspect(modificada, label: "Multiples campos")

# CUIDADO: no puedes agregar campos nuevos
# %Persona{original | nuevo_campo: "x"}  # KeyError!

# Map.put funciona pero NO ES RECOMENDADO
# porque rompe las garantias del struct
mapa_roto = Map.put(original, :campo_extra, "valor")
IO.inspect(mapa_roto, label: "Map.put agrega campo (NO RECOMENDADO)")

# ==========================================
# PATTERN MATCHING
# ==========================================

IO.puts("\n--- PATTERN MATCHING ---")

defmodule Animal do
  defstruct [:especie, :nombre, :edad]
end

animal = %Animal{especie: :perro, nombre: "Firulais", edad: 5}

# Extraer campos
%Animal{nombre: n, edad: e} = animal
IO.inspect({n, e}, label: "Nombre y edad extraidos")

# Match por tipo de struct
case animal do
  %Animal{especie: :perro} -> IO.puts("Es un perro!")
  %Animal{especie: :gato} -> IO.puts("Es un gato!")
  %Animal{} -> IO.puts("Es algun animal")
  _ -> IO.puts("No es un animal")
end

# Match especifico del struct (no matchea maps normales)
mapa_comun = %{especie: :perro, nombre: "Rex", edad: 3}

es_animal? = case mapa_comun do
  %Animal{} -> true
  _ -> false
end
IO.inspect(es_animal?, label: "Map comun matchea Animal?")

# ==========================================
# __struct__ - CAMPO ESPECIAL
# ==========================================

IO.puts("\n--- __struct__ ---")

usuario = %Usuario{nombre: "Test"}

# Todo struct tiene el campo __struct__ con el nombre del modulo
IO.inspect(usuario.__struct__, label: "__struct__")

# Esto es lo que permite distinguir structs de maps
IO.inspect(Map.keys(usuario), label: "Claves del struct (incluye __struct__)")

# Verificar tipo de struct
IO.inspect(usuario.__struct__ == Usuario, label: "Es Usuario?")

# ==========================================
# FUNCIONES EN EL MODULO DEL STRUCT
# ==========================================

IO.puts("\n--- FUNCIONES EN MODULO ---")

defmodule Cuenta do
  defstruct saldo: 0, titular: nil

  # Funcion para crear con validacion
  def nueva(titular, saldo_inicial \\ 0) when saldo_inicial >= 0 do
    %Cuenta{titular: titular, saldo: saldo_inicial}
  end

  # Operaciones
  def depositar(%Cuenta{saldo: s} = cuenta, monto) when monto > 0 do
    %Cuenta{cuenta | saldo: s + monto}
  end

  def retirar(%Cuenta{saldo: s} = cuenta, monto) when monto > 0 and monto <= s do
    {:ok, %Cuenta{cuenta | saldo: s - monto}}
  end

  def retirar(%Cuenta{}, _monto) do
    {:error, :fondos_insuficientes}
  end

  # Consulta
  def saldo(%Cuenta{saldo: s}), do: s
end

cuenta = Cuenta.nueva("Juan", 1000)
IO.inspect(cuenta, label: "Cuenta nueva")

cuenta = Cuenta.depositar(cuenta, 500)
IO.inspect(Cuenta.saldo(cuenta), label: "Saldo despues de deposito")

case Cuenta.retirar(cuenta, 2000) do
  {:ok, c} -> IO.inspect(c, label: "Retiro exitoso")
  {:error, razon} -> IO.inspect(razon, label: "Error en retiro")
end

# ==========================================
# STRUCTS ANIDADOS
# ==========================================

IO.puts("\n--- STRUCTS ANIDADOS ---")

defmodule Direccion do
  defstruct [:calle, :numero, :ciudad, pais: "Argentina"]
end

defmodule Cliente do
  defstruct [:nombre, :direccion]
end

cliente = %Cliente{
  nombre: "Maria",
  direccion: %Direccion{
    calle: "Av. Corrientes",
    numero: 1234,
    ciudad: "Buenos Aires"
  }
}

IO.inspect(cliente, label: "Cliente con direccion")
IO.inspect(cliente.direccion.ciudad, label: "Ciudad del cliente")

# Actualizar campo anidado
cliente_actualizado = %Cliente{cliente |
  direccion: %Direccion{cliente.direccion | numero: 5678}
}
IO.inspect(cliente_actualizado.direccion.numero, label: "Numero actualizado")

# Con put_in (mas elegante)
cliente_con_put_in = put_in(cliente.direccion.ciudad, "Cordoba")
IO.inspect(cliente_con_put_in.direccion.ciudad, label: "Ciudad con put_in")

# ==========================================
# DERIVE - PROTOCOLOS
# ==========================================

IO.puts("\n--- DERIVE ---")

defmodule Secreto do
  # @derive permite implementar protocolos automaticamente
  # Inspect es util para ocultar campos sensibles
  @derive {Inspect, only: [:id, :tipo]}

  defstruct [:id, :tipo, :password, :token]
end

secreto = %Secreto{id: 1, tipo: :admin, password: "123456", token: "abc"}
IO.inspect(secreto, label: "Secreto (campos ocultos)")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

defmodule Test do
  defstruct [:campo]
end

# Struct vs Map: el struct NO matchea un map comun
mapa = %{campo: "valor", __struct__: Test}
IO.inspect(mapa.__struct__, label: "__struct__ en map")
# Pero NO es un struct real!
# %Test{} = mapa  # MatchError!

# Verificar si es struct real
es_struct? = is_struct(mapa)
IO.inspect(es_struct?, label: "is_struct? del map falso")

es_struct_real? = is_struct(%Test{campo: "x"})
IO.inspect(es_struct_real?, label: "is_struct? de struct real")

# Crear struct desde map
desde_map = struct(Test, %{campo: "desde map"})
IO.inspect(desde_map, label: "struct/2 desde map")

# struct! es estricto (falla con claves invalidas)
# struct!(Test, %{campo: "x", extra: "y"})  # KeyError!
IO.puts("struct!/2 falla con claves extra")

# struct/2 ignora claves invalidas
desde_map_extra = struct(Test, %{campo: "x", extra: "ignorado"})
IO.inspect(desde_map_extra, label: "struct/2 ignora claves extra")

# Convertir struct a map (sin __struct__)
struct_original = %Test{campo: "valor"}
como_map = Map.from_struct(struct_original)
IO.inspect(como_map, label: "Map.from_struct (sin __struct__)")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n--- RESUMEN ---")

IO.puts("""
STRUCTS:
- Son maps con claves fijas (definidas en compilacion)
- Se definen con defstruct dentro de un modulo
- Pueden tener valores default
- @enforce_keys hace campos obligatorios
- El campo __struct__ guarda el nombre del modulo
- Permiten pattern matching por tipo: %MiStruct{}
- Acceso con . da error en compilacion si el campo no existe
- Usar struct/2 para crear desde map
- Usar Map.from_struct/1 para convertir a map

CUANDO USAR:
- Datos de dominio con estructura conocida
- Cuando quieres validacion en compilacion
- Cuando necesitas distinguir "tipos" de datos
- Para encapsular logica relacionada en el modulo
""")
