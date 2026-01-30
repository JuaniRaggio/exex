suma = fn a, b -> a + b end
transform = fn str -> str |> String.trim() |> String.to_integer() end

IO.puts(
  suma.(
    IO.gets("Ingrese a (entero sino falla): ") |> transform.(),
    IO.gets("Ingrese b (entero sino falla): ") |> transform.()
  )
)
