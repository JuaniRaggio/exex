# ==========================================
# LINKS Y MONITORS - SUPERVISION DE PROCESOS
# ==========================================
#
# En sistemas reales, los procesos pueden fallar.
# Elixir provee mecanismos para detectar y manejar fallas:
# - Links: conexion bidireccional (si uno muere, el otro tambien)
# - Monitors: observacion unidireccional (recibir notificacion de muerte)

# ==========================================
# PROCESO QUE CRASHEA
# ==========================================

IO.puts("=== CRASH AISLADO ===")

# Por defecto, un proceso que crashea NO afecta a otros
pid_crasheante = spawn(fn ->
  Process.sleep(100)
  raise "Crash intencional!"
end)

IO.inspect(pid_crasheante, label: "PID del proceso crasheante")
Process.sleep(200)
IO.puts("El proceso principal sigue vivo despues del crash del hijo")
IO.inspect(Process.alive?(pid_crasheante), label: "Proceso crasheante vivo?")

# ==========================================
# LINKS - CONEXION BIDIRECCIONAL
# ==========================================

IO.puts("\n=== LINKS ===")

# spawn_link/1 crea un proceso Y lo linkea al proceso actual
# Si el hijo crashea, el padre tambien muere (y viceversa)

# Para demostrar esto sin matar el script, usamos Process.flag(:trap_exit, true)
# Esto convierte las senales de exit en mensajes

Process.flag(:trap_exit, true)

pid_linkeado = spawn_link(fn ->
  Process.sleep(100)
  exit(:crash_controlado)  # exit mas suave que raise
end)

IO.inspect(pid_linkeado, label: "PID linkeado")

# Recibir la senal de exit como mensaje
receive do
  {:EXIT, pid, razon} ->
    IO.puts("Proceso #{inspect(pid)} termino con razon: #{inspect(razon)}")
after
  200 -> IO.puts("No recibi senal de exit")
end

# ==========================================
# LINK MANUAL
# ==========================================

IO.puts("\n=== LINK MANUAL ===")

# Tambien podemos linkear despues de crear el proceso
pid1 = spawn(fn ->
  receive do
    :stop -> :ok
  end
end)

# Crear link manualmente
Process.link(pid1)
IO.puts("Proceso linkeado manualmente")

# Verificar links
IO.inspect(Process.info(self(), :links), label: "Links del proceso actual")

# Desconectar el link
Process.unlink(pid1)
IO.inspect(Process.info(self(), :links), label: "Despues de unlink")

# Limpiar
send(pid1, :stop)

# ==========================================
# MONITORS - OBSERVACION UNIDIRECCIONAL
# ==========================================

IO.puts("\n=== MONITORS ===")

# A diferencia de links:
# - Monitors son unidireccionales
# - El observador recibe un mensaje, NO muere
# - Mas seguro para supervisar procesos externos

pid_monitoreado = spawn(fn ->
  Process.sleep(100)
  :terminado_normalmente
end)

# Crear monitor
ref = Process.monitor(pid_monitoreado)
IO.inspect(ref, label: "Referencia del monitor")

# Esperar mensaje de terminacion
receive do
  {:DOWN, ^ref, :process, pid, razon} ->
    IO.puts("Proceso #{inspect(pid)} termino")
    IO.inspect(razon, label: "Razon")
after
  200 -> IO.puts("No termino")
end

# ==========================================
# MONITOR CON CRASH
# ==========================================

IO.puts("\n=== MONITOR CON CRASH ===")

pid_crash = spawn(fn ->
  Process.sleep(100)
  raise "Error en proceso monitoreado!"
end)

ref_crash = Process.monitor(pid_crash)

receive do
  {:DOWN, ^ref_crash, :process, pid, razon} ->
    IO.puts("Proceso monitoreado crasheo")
    IO.inspect(razon, label: "Razon del crash")
after
  200 -> :ok
end

IO.puts("El proceso principal sigue vivo (gracias al monitor)")

# ==========================================
# spawn_monitor/1 - ATAJO
# ==========================================

IO.puts("\n=== spawn_monitor ===")

# Crea proceso Y monitor en una sola llamada
{pid, ref} = spawn_monitor(fn ->
  Process.sleep(50)
  :done
end)

IO.inspect({pid, ref}, label: "PID y referencia")

receive do
  {:DOWN, ^ref, :process, ^pid, razon} ->
    IO.inspect(razon, label: "Terminacion")
after
  100 -> :ok
end

# ==========================================
# DEMONITOR - CANCELAR MONITOR
# ==========================================

IO.puts("\n=== DEMONITOR ===")

pid_largo = spawn(fn ->
  Process.sleep(10_000)
end)

ref = Process.monitor(pid_largo)

# Ya no nos interesa monitorearlo
Process.demonitor(ref)
IO.puts("Monitor cancelado")

# Matar el proceso manualmente
Process.exit(pid_largo, :kill)

# No recibiremos mensaje DOWN porque cancelamos el monitor
receive do
  {:DOWN, _, _, _, _} -> IO.puts("Recibi DOWN (no deberia)")
after
  100 -> IO.puts("No recibi DOWN (correcto, demonitor funciono)")
end

# ==========================================
# LINKS vs MONITORS
# ==========================================

IO.puts("\n=== COMPARACION ===")

IO.puts("""
LINKS:
- Bidireccionales
- Si uno muere, el otro tambien (por defecto)
- Usados para procesos que DEBEN morir juntos
- Ejemplo: proceso y su supervisor

MONITORS:
- Unidireccionales
- Solo notificacion, no muerte
- Usados para observar sin acoplamiento
- Ejemplo: monitorear workers temporales

CUANDO USAR CADA UNO:
- Link: "Si yo muero, vos tambien debes morir"
- Monitor: "Quiero saber cuando mueras, pero no morir yo"
""")

# ==========================================
# TRAP EXIT EN DETALLE
# ==========================================

IO.puts("\n=== TRAP EXIT ===")

# Por defecto: si un proceso linkeado muere, vos tambien
# Con trap_exit: recibes un mensaje en lugar de morir

# Ya tenemos trap_exit en true desde antes

pid_exit = spawn_link(fn ->
  exit(:adios)
end)

receive do
  {:EXIT, ^pid_exit, razon} ->
    IO.inspect(razon, label: "Exit atrapado")
after
  100 -> :ok
end

# ==========================================
# PATRON: REINICIAR PROCESO FALLIDO
# ==========================================

IO.puts("\n=== REINICIAR PROCESO ===")

defmodule SupervisorSimple do
  def iniciar(funcion) do
    spawn(fn ->
      Process.flag(:trap_exit, true)
      loop(funcion, nil)
    end)
  end

  defp loop(funcion, pid_actual) do
    pid = if pid_actual && Process.alive?(pid_actual) do
      pid_actual
    else
      IO.puts("Iniciando/Reiniciando worker...")
      spawn_link(funcion)
    end

    receive do
      {:EXIT, ^pid, :normal} ->
        IO.puts("Worker termino normalmente")
        :ok  # No reiniciar si termino bien

      {:EXIT, ^pid, razon} ->
        IO.puts("Worker crasheo: #{inspect(razon)}")
        loop(funcion, nil)  # Reiniciar

      :stop ->
        Process.exit(pid, :shutdown)
        :ok
    end
  end
end

# Worker que puede crashear
worker_fn = fn ->
  IO.puts("Worker iniciado (PID: #{inspect(self())})")
  receive do
    :crash -> raise "Crash intencional!"
    :work -> IO.puts("Trabajando...")
  end
end

# Iniciar supervisor
sup = SupervisorSimple.iniciar(worker_fn)
Process.sleep(100)

# Encontrar el worker y hacerlo crashear
# (En la practica usarias el supervisor para comunicarte)
IO.puts("Enviando :crash al worker a traves del proceso")
# El supervisor reiniciara automaticamente

Process.sleep(200)
send(sup, :stop)

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
FUNCIONES CLAVE:
- spawn_link/1: crear + linkear
- Process.link/1: linkear manualmente
- Process.unlink/1: deslinkear
- spawn_monitor/1: crear + monitorear
- Process.monitor/1: monitorear manualmente
- Process.demonitor/1: cancelar monitor
- Process.flag(:trap_exit, true): convertir exits en mensajes

MENSAJES:
- Link con trap_exit: {:EXIT, pid, razon}
- Monitor: {:DOWN, ref, :process, pid, razon}

SIGUIENTE: ver 04_genserver.exs para abstraccion de servidores
""")
