suma = fn a, b -> a + b end
transform = fn str -> str |> String.trim() |> String.to_integer() end
# La sintaxis para aplicar estas funciones es importante usar el . antes del parentesis

IO.puts(
  suma.(
    IO.gets("Ingrese a (entero sino falla): ") |> transform.(),
    IO.gets("Ingrese b (entero sino falla): ") |> transform.()
  )
)

# Como capturar funciones?

defmodule Capturas do
  def operar(a, funct) do
    funct.(a)
  end
end

# Suponiendo que quiero operar sobre a
# Es importante aclarar la aridad que se quiere usar
Capturas.operar("Hola mundo!", &IO.puts/1)

# Si envio una lambda, evidentemente no es necesario que pasemos la referencia
# especificando la aridad. Esto es porque por ejemplo puts esta sobrecargada
# por lo que decir solo puts no deja claro que referencia tiene que tomar
Capturas.operar("Hola mundo!", fn str -> str |> IO.puts() end)

