defmodule Example do
  use Application
  def start(_type, _args) do
    # code
    "Juani" |> Example.hello
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def hello(name) do
    "Hello #{name}" |> IO.puts
  end
end
