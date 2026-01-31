# ==========================================
# INTRODUCCION A LA CONCURRENCIA EN ELIXIR
# ==========================================
#
# Elixir corre sobre la BEAM (Erlang Virtual Machine), que fue
# disenada especificamente para sistemas concurrentes y distribuidos.
#
# CONCEPTOS CLAVE:
# - Los PROCESOS en Elixir son livianos (no son threads del SO)
# - Cada proceso tiene su propia memoria (no comparten estado)
# - Los procesos se comunican mediante mensajes
# - Pueden existir millones de procesos simultaneamente
#
# CONCURRENCIA vs PARALELISMO:
# - CONCURRENCIA: multiples tareas progresando (pueden alternarse)
# - PARALELISMO: multiples tareas ejecutandose al mismo tiempo (requiere multiples CPUs)
# Elixir soporta AMBOS de forma nativa.

# ==========================================
# MODELO DE ACTORES
# ==========================================
#
# Elixir usa el "Actor Model":
# - Cada proceso es un "actor"
# - Los actores tienen estado privado (nadie mas puede acceder)
# - Los actores se comunican solo via mensajes
# - Cada actor procesa UN mensaje a la vez (secuencialmente)
# - No hay locks, mutexes, ni semaforos (no los necesitas!)
#
# Esto elimina los problemas clasicos de concurrencia:
# - Race conditions: imposible (estado no compartido)
# - Deadlocks: muy raros (no hay locks)
# - Data corruption: imposible (datos inmutables)

# ==========================================
# PID - PROCESS IDENTIFIER
# ==========================================

IO.puts("=== PROCESO ACTUAL ===")

# Cada proceso tiene un PID unico
pid_actual = self()
IO.inspect(pid_actual, label: "PID del proceso actual")

# El PID tiene formato #PID<x.y.z>
# x.y.z son numeros que identifican el proceso

# Verificar si un PID esta vivo
IO.inspect(Process.alive?(pid_actual), label: "Esta vivo?")

# ==========================================
# SPAWN - CREAR PROCESOS
# ==========================================

IO.puts("\n=== SPAWN BASICO ===")

# spawn/1 crea un nuevo proceso y retorna su PID
# El proceso ejecuta la funcion dada y luego MUERE

pid_nuevo = spawn(fn ->
  IO.puts("Hola desde un proceso nuevo!")
  IO.inspect(self(), label: "Mi PID")
end)

IO.inspect(pid_nuevo, label: "PID del proceso creado")

# Pequenia pausa para que el proceso termine
Process.sleep(100)

IO.inspect(Process.alive?(pid_nuevo), label: "Sigue vivo despues de terminar?")

# ==========================================
# PROCESOS SON AISLADOS
# ==========================================

IO.puts("\n=== AISLAMIENTO DE PROCESOS ===")

# Los procesos NO comparten memoria
# Las variables del proceso padre NO son visibles en el hijo
# (a menos que se pasen explicitamente)

mensaje = "Hola"

spawn(fn ->
  # Esto funciona porque Elixir "captura" el valor de mensaje
  # al momento de crear el proceso (closure)
  IO.puts("Mensaje capturado: #{mensaje}")
end)

Process.sleep(50)

# Si un proceso crashea, NO afecta a otros procesos
# (a menos que esten "linked" - veremos esto mas adelante)

spawn(fn ->
  raise "Este proceso va a crashear!"
end)

Process.sleep(50)
IO.puts("El proceso principal sigue vivo!")

# ==========================================
# PROCESOS SON LIVIANOS
# ==========================================

IO.puts("\n=== PROCESOS LIVIANOS ===")

# Podemos crear MILES de procesos sin problema
# Cada proceso usa solo ~2KB de memoria inicial

# Crear 1000 procesos
pids = for i <- 1..1000 do
  spawn(fn ->
    # Cada proceso espera un poco para demostrar que existen simultaneamente
    Process.sleep(100)
    :ok
  end)
end

IO.puts("Creados #{length(pids)} procesos")

# Contar cuantos estan vivos
vivos = Enum.count(pids, &Process.alive?/1)
IO.puts("Procesos vivos: #{vivos}")

Process.sleep(150)

vivos_despues = Enum.count(pids, &Process.alive?/1)
IO.puts("Procesos vivos despues de esperar: #{vivos_despues}")

# ==========================================
# INFORMACION DE PROCESOS
# ==========================================

IO.puts("\n=== INFORMACION DE PROCESOS ===")

# Process.info/1 da informacion sobre un proceso
info = Process.info(self())
IO.inspect(Keyword.take(info, [:memory, :message_queue_len, :status]), label: "Info del proceso actual")

# Cantidad total de procesos en el sistema
IO.inspect(length(Process.list()), label: "Total de procesos en el sistema")

# ==========================================
# DIFERENCIA CON THREADS TRADICIONALES
# ==========================================

IO.puts("\n=== POR QUE PROCESOS Y NO THREADS ===")

IO.puts("""
THREADS DEL SO (Java, C++, etc):
- Pesados (~1MB de stack por thread)
- Comparten memoria (problemas de race conditions)
- Requieren locks/mutexes (problemas de deadlocks)
- Limite practico: cientos a miles

PROCESOS DE ERLANG/ELIXIR:
- Ultra livianos (~2KB inicial)
- Memoria aislada (sin race conditions)
- Comunicacion por mensajes (sin locks)
- Limite practico: millones

El scheduler de la BEAM es preemptive:
- Ningun proceso puede bloquear a otros
- Cada proceso recibe tiempo justo
- Operaciones I/O no bloquean otros procesos
""")

# ==========================================
# REGISTERED NAMES
# ==========================================

IO.puts("\n=== NOMBRES DE PROCESOS ===")

# Podemos registrar un proceso con un nombre (atom)
pid_con_nombre = spawn(fn ->
  Process.sleep(1000)
end)

# Registrar con un nombre
Process.register(pid_con_nombre, :mi_proceso)

# Ahora podemos encontrarlo por nombre
IO.inspect(Process.whereis(:mi_proceso), label: "PID de :mi_proceso")

# Verificar si esta registrado
IO.inspect(Process.registered() |> Enum.member?(:mi_proceso), label: "Esta registrado?")

# ==========================================
# PROXIMO: COMUNICACION ENTRE PROCESOS
# ==========================================

IO.puts("\n=== SIGUIENTE TEMA ===")
IO.puts("Ver 02_send_receive.exs para comunicacion entre procesos")
