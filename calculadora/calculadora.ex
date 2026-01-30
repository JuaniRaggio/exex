# Los modulos tienen que estar capitalizados
defmodule Calculadora do
  # suma\2 => el \<numero> indica la aridad de la funcion
  # Puede haber overload de funciones siempre y cuando tengan
  # distinta aridad
  def suma(a, b) do
    IO.puts("Esta funcion retorna a + b = #{a} + #{b} = #{a + b}")
  end
end

a = IO.gets("Ingrese a: ") |> String.trim |> String.to_integer
b = IO.gets("Ingrese b: ") |> String.trim |> String.to_integer
Calculadora.suma(a, b) |> IO.puts

