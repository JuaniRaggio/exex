edad = IO.gets("Ingrese su edad: ") |> String.trim() |> String.to_integer()

# Esto tambien podria en lineas separadas y sigue retornando en su nombre
if edad >= 18 do
  "Mayor de edad"
else
  "Menor de edad"
end
|> IO.puts()

unless edad < 18 do
  IO.puts("Podes pasar pero no te hagas el loco")
else
  IO.puts("Volve a tu casa pichon")
end

lluvia =
  IO.gets("Cuanto llovio del 0 al 10?\n")
  |> String.trim()
  |> String.to_integer()

cond do
  lluvia <= 0 -> "No llovio"
  lluvia <= 4 -> "Llovizno"
  lluvia <= 7 -> "Llovio"
  lluvia <= 9 -> "Llovio a cantaros"
  true -> "Madre mia la que ha caido chaval"
end
