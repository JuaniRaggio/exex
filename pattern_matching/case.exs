# En el caso de los case, a diferencia del cond
# va a matchear con pattern matching, mientras que el cond
# y el if matchean con valores nomas. Por lo tanto es IMPORTANTISIMO
# entender el concepto de pattern matching

exp = {:ok, 5}

output =
  case exp do
    {:ok, x} when is_number(x) -> "Number x = #{x} matched ok!"
    {:ok, x} -> "x = #{x} matched ok!"
    {:error, y} when is_atom(y) -> "Atom y = #{y} ,matched error"
    _ -> "Unknown match (matches anything)"
  end
