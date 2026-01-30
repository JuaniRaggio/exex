# Los modulos tienen que estar capitalizados
defmodule Calculadora do
  # suma\2 => el \<numero> indica la aridad de la funcion
  # Puede haber overload de funciones siempre y cuando tengan
  # distinta aridad
  def suma(a, b) do
    IO.puts("Esta funcion retorna a + b = #{a} + #{b} = #{a + b}")
  end

  def resta(a, b) do
    a - b
  end

  def mult(a, b) do
    a * b
  end

  # esto seria una forma 'no funcional' de hacerlo
  # def div(a, b) do
  #   if b == 0 do
  #     return :inf
  #   end
  #   a / b
  # end

  # ***** Esta seria la forma mas funcional ***** #
  # Se usa leading _ para parametros que no se usan
  def div(_a, b) when b == 0 do
    :inf
  end

  def div(a, b) do
    a / b
  end

  # ********************************************* #
end

a = IO.gets("Ingrese a: ") |> String.trim() |> String.to_integer()
b = IO.gets("Ingrese b: ") |> String.trim() |> String.to_integer()
Calculadora.suma(a, b) |> IO.puts()
