x = 5
y = "Esto es y"
z = :esto_es_z
ejemplo_tupla = {x, y, z}

# Esto devuelve una COPIA, no hay metodos asociados a 
# variables como en poo ya que los valores son inmutables
# Esto es una ventaja enorme a la hora de trabajar con
# sistemas concurrentes ya que hay menos chances de cometer
# errores
# Este metodo esta deprecado y se usa insert_at
# esta_es_otra_tupla = Tuple.append(ejemplo_tupla, :agregado)

# Con insert_at podes aclarar en que indice queres insertar
# pero no podes dejar 'un espacio libre', tiene que 
# mantenerse continua la tupla, es decir no podriamos agregar
# al indice 6 por ejemplo a menos de que la tulpa tenga 6 o 
# mas elementos
esta_es_otra_tupla = Tuple.insert_at(ejemplo_tupla, 1, :agregado)
# Aca quedaria: {5, :agregado, "Esto es y", :esto_es_z}

IO.puts(elem(esta_es_otra_tupla, 3)) # Aca deberia mostrar :esto_es_z

# Esto no es valido porque el protocolo String.chars no esta
# implementado para tuplas
# ejemplo_tupla |> IO.puts()

