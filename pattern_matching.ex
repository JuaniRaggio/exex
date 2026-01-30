# Aca tenemos true porque las tuplas implementan la comp
{:hello, :goodbye} == {:hello, :goodbye}

# Aca vamos a obtener un error porque a y b no existen
# {a, b} == {:hello, :goodbye}

# aca tambien tendriamos error porque a  no existe
# {2, a, 1} == {1, 2, 1}
# pero ojo porque lo que si podriamos hacer es
{2, a, 1} = {1, 2, 1}
# el problema es que no hay forma de hacer que esto se
# evalue en true, por lo tanto si vamos a obtener un 
# MatchError

# Elixir busca la forma de que las expresiones se evaluen
# a true, entonces tenemos lo siguiente:
# en este caso a va a pasar a ser :hello y b :goodbye
{a, b} = {:hello, :goodbye}
#
# Pero como dijimos, Elixir siempre busca la forma de que
# las expresiones se evaluen a true, por lo que
# el siguiente caso si es correcto y a pasaria a ser 2
{1, a, 3} = {1, 2, 3}


