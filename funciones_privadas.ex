defmodule Impuestos do
  def total(precio, tipo) do
    porcentaje(tipo) + precio
  end

  # ***** Esta funcion es privada ***** #
  defp porcentaje(tipo) do
    cond do
      tipo == :normal -> 0.1
      tipo == :sexo -> 0.9
    end
  end
end
