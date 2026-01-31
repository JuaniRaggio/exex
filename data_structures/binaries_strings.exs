# ==========================================
# BINARIES Y STRINGS EN ELIXIR
# ==========================================
# En Elixir, los strings son BINARIES codificados en UTF-8
# Un binary es una secuencia de bytes
# Esto es fundamental para entender como funciona el texto

# ==========================================
# BINARIES BASICOS
# ==========================================

# Binary literal con << >>
bin = <<1, 2, 3>>
IO.inspect(bin, label: "Binary basico")
IO.inspect(byte_size(bin), label: "Tamanio en bytes")

# Cada valor es un byte (0-255)
bin2 = <<255, 0, 128>>
IO.inspect(bin2, label: "Binary con valores 0-255")

# Si el valor excede 255, se trunca!
truncado = <<256, 257, 258>>
IO.inspect(truncado, label: "Valores > 255 truncados (mod 256)")
# 256 mod 256 = 0, 257 mod 256 = 1, 258 mod 256 = 2

# Especificar tamanio en bits
bits = <<3::size(2), 5::size(4), 1::size(2)>>
IO.inspect(bits, label: "Binary con bits especificos")
IO.inspect(byte_size(bits), label: "Total: 1 byte")

# ==========================================
# STRINGS (UTF-8 Binaries)
# ==========================================

IO.puts("\n--- STRINGS ---")

# Los strings son binaries UTF-8
str = "Hola"
IO.inspect(str, label: "String")
IO.inspect(is_binary(str), label: "Es binary?")

# byte_size vs String.length
IO.inspect(byte_size(str), label: "byte_size (bytes)")
IO.inspect(String.length(str), label: "String.length (caracteres)")

# Con caracteres especiales/acentos
utf8 = "Hola Munio"
IO.inspect(byte_size(utf8), label: "Bytes de 'Hola Munio'")
IO.inspect(String.length(utf8), label: "Caracteres de 'Hola Munio'")

# Emojis usan multiples bytes
emoji = "Hola"
IO.inspect(byte_size(emoji), label: "Bytes (emoji usa 4 bytes)")
IO.inspect(String.length(emoji), label: "Caracteres")

# ==========================================
# STRING OPERATIONS
# ==========================================

IO.puts("\n--- OPERACIONES CON STRINGS ---")

# Concatenacion
concat = "Hola" <> " " <> "Mundo"
IO.inspect(concat, label: "Concatenacion <>")

# Interpolacion
nombre = "Juan"
saludo = "Hola, #{nombre}!"
IO.inspect(saludo, label: "Interpolacion")

# Funciones de String
texto = "  Elixir es genial  "

IO.inspect(String.trim(texto), label: "trim")
IO.inspect(String.upcase("hola"), label: "upcase")
IO.inspect(String.downcase("HOLA"), label: "downcase")
IO.inspect(String.capitalize("hola mundo"), label: "capitalize")
IO.inspect(String.reverse("hola"), label: "reverse")

# Split y Join
IO.inspect(String.split("a,b,c", ","), label: "split por coma")
IO.inspect(String.split("hola mundo"), label: "split por espacio")
IO.inspect(Enum.join(["a", "b", "c"], "-"), label: "join con guion")

# Contains, starts_with, ends_with
IO.inspect(String.contains?("hello world", "world"), label: "contains?")
IO.inspect(String.starts_with?("hello", "he"), label: "starts_with?")
IO.inspect(String.ends_with?("hello", "lo"), label: "ends_with?")

# Replace
IO.inspect(String.replace("hello world", "world", "elixir"), label: "replace")
IO.inspect(String.replace("aaa", "a", "b", global: false), label: "replace solo primero")

# Slice
IO.inspect(String.slice("hello", 0, 3), label: "slice(0, 3)")
IO.inspect(String.slice("hello", -2, 2), label: "slice(-2, 2)")

# ==========================================
# GRAPHEMES vs CODEPOINTS
# ==========================================

IO.puts("\n--- GRAPHEMES vs CODEPOINTS ---")

# Grapheme = lo que visualmente es un caracter
# Codepoint = numero Unicode

texto = "Jose"
IO.inspect(String.graphemes(texto), label: "graphemes")
IO.inspect(String.codepoints(texto), label: "codepoints")

# Caracteres compuestos (e + acento combinado)
compuesto = "e\u0301"  # e + combining acute accent
IO.inspect(compuesto, label: "e + acento combinado")
IO.inspect(String.length(compuesto), label: "length")
IO.inspect(String.graphemes(compuesto), label: "graphemes")
IO.inspect(String.codepoints(compuesto), label: "codepoints (son 2!)")

# Por eso SIEMPRE usar String.length, no byte_size para contar caracteres

# ==========================================
# CHARLISTS (LISTAS DE CARACTERES)
# ==========================================

IO.puts("\n--- CHARLISTS ---")

# Charlist = lista de codepoints (integers)
# Se crean con comillas simples
charlist = 'hello'
IO.inspect(charlist, label: "Charlist")
IO.inspect(is_list(charlist), label: "Es lista?")

# Internamente es una lista de integers
IO.inspect(charlist, charlists: :as_lists, label: "Como lista de integers")

# Conversion entre string y charlist
str = "hello"
charlist_from_str = String.to_charlist(str)
str_from_charlist = List.to_string(charlist)
IO.inspect(charlist_from_str, label: "String a charlist")
IO.inspect(str_from_charlist, label: "Charlist a string")

# CUIDADO: charlists se usan poco en Elixir moderno
# Principalmente para interop con Erlang
IO.puts("Charlists: usar para compatibilidad con Erlang")

# ==========================================
# PATTERN MATCHING CON BINARIES
# ==========================================

IO.puts("\n--- PATTERN MATCHING ---")

# Extraer bytes
<<a, b, c>> = <<1, 2, 3>>
IO.inspect({a, b, c}, label: "Bytes extraidos")

# Con strings (UTF-8)
<<first::utf8, rest::binary>> = "Hola"
IO.inspect(first, label: "Primer codepoint")
IO.inspect(<<first::utf8>>, label: "Como caracter")
IO.inspect(rest, label: "Resto del string")

# Extraer prefijo fijo
<<"Hola ", nombre::binary>> = "Hola Juan"
IO.inspect(nombre, label: "Nombre extraido")

# Con tamanio especifico
<<cabecera::binary-size(4), datos::binary>> = "HTTP/1.1 200 OK"
IO.inspect(cabecera, label: "Cabecera (4 bytes)")
IO.inspect(datos, label: "Datos restantes")

# Bits especificos
<<x::4, y::4>> = <<0xAB>>
IO.inspect({x, y}, label: "Nibbles de 0xAB")

# ==========================================
# SIGILS PARA STRINGS
# ==========================================

IO.puts("\n--- SIGILS ---")

# ~s - string con interpolacion
nombre = "Elixir"
s1 = ~s(Hola #{nombre})
IO.inspect(s1, label: "~s con interpolacion")

# ~S - string SIN interpolacion
s2 = ~S(Hola #{nombre})
IO.inspect(s2, label: "~S sin interpolacion")

# ~w - lista de palabras
palabras = ~w(uno dos tres)
IO.inspect(palabras, label: "~w lista de palabras")

# ~w con atoms
atomos = ~w(uno dos tres)a
IO.inspect(atomos, label: "~w con 'a' (atoms)")

# Heredocs (strings multilinea)
multilinea = """
Esta es una
cadena multilinea
con "comillas" dentro
"""
IO.inspect(multilinea, label: "Heredoc")

# ==========================================
# REGEX CON STRINGS
# ==========================================

IO.puts("\n--- REGEX ---")

# Crear regex
regex = ~r/\d+/
IO.inspect(Regex.match?(regex, "abc123def"), label: "match? digitos")

# Scan - encontrar todas las ocurrencias
IO.inspect(Regex.scan(~r/\d+/, "a1b22c333"), label: "scan digitos")

# Replace con regex
IO.inspect(Regex.replace(~r/\s+/, "a  b   c", "-"), label: "replace espacios")

# Named captures
regex = ~r/(?<nombre>\w+)@(?<dominio>\w+)/
resultado = Regex.named_captures(regex, "juan@mail")
IO.inspect(resultado, label: "named_captures")

# ==========================================
# EDGE CASES
# ==========================================

IO.puts("\n--- EDGE CASES ---")

# String vacio
vacio = ""
IO.inspect(byte_size(vacio), label: "byte_size de string vacio")
IO.inspect(String.length(vacio), label: "length de string vacio")

# nil NO es string
# String.length(nil)  # FunctionClauseError!
IO.puts("CUIDADO: String.length(nil) causa error")

# Concatenar nil requiere conversion
# "hola" <> nil  # ArgumentError!
IO.puts("CUIDADO: 'hola' <> nil causa error")

# Solucion: usar to_string o interpolacion
valor = nil
seguro = "valor: #{valor}"
IO.inspect(seguro, label: "nil con interpolacion")

# String con null bytes (valido en Elixir)
con_null = "hola\0mundo"
IO.inspect(byte_size(con_null), label: "String con null byte")

# Comparacion de strings es lexicografica
IO.inspect("abc" < "abd", label: "'abc' < 'abd'")
IO.inspect("abc" < "abcd", label: "'abc' < 'abcd'")

# Case sensitive
IO.inspect("ABC" == "abc", label: "'ABC' == 'abc'")

# Para comparar sin case
IO.inspect(String.downcase("ABC") == String.downcase("abc"), label: "Comparacion sin case")

# ==========================================
# IO CON STRINGS
# ==========================================

IO.puts("\n--- IO ---")

# IO.puts vs IO.write vs IO.inspect
IO.puts("IO.puts agrega newline")
IO.write("IO.write no agrega newline\n")
IO.inspect("IO.inspect muestra representacion", label: "IO.inspect")

# Leer input (comentado porque es interactivo)
# nombre = IO.gets("Ingresa tu nombre: ")
# IO.puts("Hola, #{String.trim(nombre)}!")

# ==========================================
# BINARIES PARA DATOS BINARIOS
# ==========================================

IO.puts("\n--- USO COMO DATOS BINARIOS ---")

# Ejemplo: procesar formato de imagen (header ficticio)
png_header = <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
IO.inspect(png_header, label: "PNG header (bytes)")

# Verificar firma
case png_header do
  <<0x89, "PNG", _rest::binary>> ->
    IO.puts("Es un archivo PNG!")
  _ ->
    IO.puts("No es PNG")
end

# Ejemplo: parsear paquete de red simple
paquete = <<1, 0, 5, "Hello">>
<<version, _flags, length, payload::binary-size(length)>> = paquete
IO.inspect(%{version: version, length: length, payload: payload}, label: "Paquete parseado")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n--- RESUMEN ---")

IO.puts("""
BINARIES:
- Secuencia de bytes: <<1, 2, 3>>
- byte_size/1 para tamanio
- Pattern matching poderoso

STRINGS:
- Son binaries UTF-8
- Usar String.length/1, no byte_size
- String.graphemes/1 para caracteres visuales
- Concatenar con <> o interpolacion #{}

CHARLISTS:
- Listas de codepoints: 'hello'
- Usadas para Erlang interop
- Convertir con to_charlist/to_string

SIGILS:
- ~s, ~S para strings
- ~r para regex
- ~w para lista de palabras

EDGE CASES:
- nil no es string
- Emojis/acentos usan multiples bytes
- byte_size != String.length con UTF-8
""")
