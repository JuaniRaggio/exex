defmodule Intro do
  def sub(a, b) do
    a - b
  end
end

# El 10 va a ser el primer parametro
10 |> Intro.sub(11) |> IO.puts

