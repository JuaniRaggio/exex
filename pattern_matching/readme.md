# Pattern Matching

Siempre que llamamos a una funcion en elixir se intenta
hacer pattern matching con los parametros y se intenta
'matchear todo para que sea true', por lo tanto el siguiente
codigo tambien seria valido

```ex
defmodule X do
    def prueba(:ok, _cadena) do
        IO.puts "Pasate el atomo :ok"
    end

    def prueba(_atomo, cadena) do
        IO.puts cadena
    end
end
```

> [!NOTE]
> Lo que pasaria en este caso es que si llamamos a la funcion
> de la forma: `prueba(:ok, "Hola")`, se va a ejecutar la
> primera por el pattern matching. Por otro lado, si se hace
> `prueba(:hola, "hola")`, se ejecutaria la segunda ya que
> la forma posible en la que coincidan los patrones no es
> la primera, entonces pasa a la segunda y se va que si 
> podria matchear {:hola, "hola"} con {_atomo, cadena}, en
> tal caso seria como hacer:
> {_atomo, cadena} = {:hola, "hola"}

