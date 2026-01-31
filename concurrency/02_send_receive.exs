# ==========================================
# SEND Y RECEIVE - COMUNICACION ENTRE PROCESOS
# ==========================================
#
# Los procesos se comunican mediante mensajes:
# - send/2: envia un mensaje a un proceso
# - receive: espera y procesa mensajes
#
# Los mensajes son ASINCRONOS:
# - send retorna inmediatamente (no espera respuesta)
# - los mensajes se encolan en el "mailbox" del destinatario
# - receive procesa mensajes del mailbox

# ==========================================
# SEND BASICO
# ==========================================

IO.puts("=== SEND BASICO ===")

# Enviar mensaje a uno mismo
send(self(), :hola)
send(self(), {:numero, 42})
send(self(), "un string")

# Los mensajes estan en el mailbox
IO.inspect(Process.info(self(), :message_queue_len), label: "Mensajes en cola")

# ==========================================
# RECEIVE BASICO
# ==========================================

IO.puts("\n=== RECEIVE BASICO ===")

# receive usa pattern matching para procesar mensajes
receive do
  :hola -> IO.puts("Recibi :hola")
end

receive do
  {:numero, n} -> IO.puts("Recibi numero: #{n}")
end

receive do
  msg when is_binary(msg) -> IO.puts("Recibi string: #{msg}")
end

# ==========================================
# RECEIVE CON TIMEOUT
# ==========================================

IO.puts("\n=== RECEIVE CON TIMEOUT ===")

# after especifica un timeout en milisegundos
resultado = receive do
  :mensaje_que_no_llegara -> :ok
after
  1000 -> :timeout  # espera 1 segundo
end

IO.inspect(resultado, label: "Resultado con timeout")

# Timeout de 0 es util para revisar si hay mensajes sin bloquear
sin_bloquear = receive do
  cualquier -> cualquier
after
  0 -> :no_hay_mensajes
end

IO.inspect(sin_bloquear, label: "Sin bloquear")

# ==========================================
# COMUNICACION ENTRE PROCESOS
# ==========================================

IO.puts("\n=== COMUNICACION ENTRE PROCESOS ===")

# Proceso padre
padre = self()

# Crear proceso hijo que envia mensaje al padre
spawn(fn ->
  # Enviar mensaje al padre
  send(padre, {:desde_hijo, self(), "Hola padre!"})
end)

# Recibir mensaje del hijo
receive do
  {:desde_hijo, pid_hijo, mensaje} ->
    IO.puts("Padre recibio de #{inspect(pid_hijo)}: #{mensaje}")
end

# ==========================================
# PATRON REQUEST-RESPONSE
# ==========================================

IO.puts("\n=== PATRON REQUEST-RESPONSE ===")

# Patron comun: enviar mensaje y esperar respuesta
# El mensaje incluye el PID del sender para poder responder

# Crear un proceso "servidor" simple
servidor = spawn(fn ->
  receive do
    {:sumar, a, b, cliente} ->
      resultado = a + b
      send(cliente, {:resultado, resultado})
  end
end)

# Enviar request
send(servidor, {:sumar, 5, 3, self()})

# Esperar response
receive do
  {:resultado, r} ->
    IO.puts("Resultado de la suma: #{r}")
end

# ==========================================
# PROCESO CON LOOP INFINITO (SERVIDOR)
# ==========================================

IO.puts("\n=== SERVIDOR CON LOOP ===")

defmodule Calculadora do
  def iniciar do
    spawn(fn -> loop() end)
  end

  defp loop do
    receive do
      {:sumar, a, b, cliente} ->
        send(cliente, {:resultado, a + b})
        loop()  # Llamada recursiva para seguir escuchando

      {:restar, a, b, cliente} ->
        send(cliente, {:resultado, a - b})
        loop()

      {:multiplicar, a, b, cliente} ->
        send(cliente, {:resultado, a * b})
        loop()

      :detener ->
        IO.puts("Servidor detenido")
        :ok  # No llama a loop(), termina

      _ ->
        IO.puts("Mensaje desconocido")
        loop()
    end
  end
end

# Usar la calculadora
calc = Calculadora.iniciar()

# Varias operaciones
send(calc, {:sumar, 10, 5, self()})
receive do {:resultado, r} -> IO.puts("10 + 5 = #{r}") end

send(calc, {:multiplicar, 7, 6, self()})
receive do {:resultado, r} -> IO.puts("7 * 6 = #{r}") end

send(calc, {:restar, 100, 42, self()})
receive do {:resultado, r} -> IO.puts("100 - 42 = #{r}") end

send(calc, :detener)
Process.sleep(50)

# ==========================================
# SERVIDOR CON ESTADO
# ==========================================

IO.puts("\n=== SERVIDOR CON ESTADO ===")

defmodule Contador do
  def iniciar(valor_inicial \\ 0) do
    spawn(fn -> loop(valor_inicial) end)
  end

  defp loop(estado) do
    receive do
      :incrementar ->
        loop(estado + 1)

      :decrementar ->
        loop(estado - 1)

      {:sumar, n} ->
        loop(estado + n)

      {:obtener, cliente} ->
        send(cliente, {:valor, estado})
        loop(estado)

      {:establecer, nuevo_valor} ->
        loop(nuevo_valor)

      :detener ->
        :ok
    end
  end
end

contador = Contador.iniciar(10)

send(contador, :incrementar)
send(contador, :incrementar)
send(contador, :incrementar)
send(contador, {:sumar, 100})

send(contador, {:obtener, self()})
receive do {:valor, v} -> IO.puts("Valor del contador: #{v}") end

send(contador, :detener)

# ==========================================
# SELECTIVE RECEIVE
# ==========================================

IO.puts("\n=== SELECTIVE RECEIVE ===")

# receive procesa el PRIMER mensaje que matchea
# Los mensajes que no matchean quedan en el mailbox

send(self(), {:tipo_a, 1})
send(self(), {:tipo_b, 2})
send(self(), {:tipo_a, 3})

# Esto recibe {:tipo_b, 2} primero (aunque llego segundo)
receive do
  {:tipo_b, n} -> IO.puts("Tipo B: #{n}")
end

# Esto recibe {:tipo_a, 1} (el primero tipo_a)
receive do
  {:tipo_a, n} -> IO.puts("Tipo A: #{n}")
end

# Limpiar el mailbox
receive do
  {:tipo_a, n} -> IO.puts("Tipo A restante: #{n}")
after
  0 -> :ok
end

# ==========================================
# FLUSH - VACIAR MAILBOX
# ==========================================

IO.puts("\n=== FLUSH ===")

# Enviar varios mensajes
send(self(), :msg1)
send(self(), :msg2)
send(self(), :msg3)

IO.inspect(Process.info(self(), :message_queue_len), label: "Antes del flush")

# Funcion para vaciar el mailbox
defmodule Utils do
  def flush do
    receive do
      msg ->
        IO.inspect(msg, label: "Flushed")
        flush()
    after
      0 -> :ok
    end
  end
end

Utils.flush()
IO.inspect(Process.info(self(), :message_queue_len), label: "Despues del flush")

# ==========================================
# EDGE CASES Y CUIDADOS
# ==========================================

IO.puts("\n=== EDGE CASES ===")

# 1. Enviar a PID muerto - NO falla, el mensaje se pierde
pid_muerto = spawn(fn -> :ok end)
Process.sleep(50)
send(pid_muerto, :mensaje)  # No crashea, pero mensaje perdido
IO.puts("Enviar a PID muerto no crashea")

# 2. receive sin mensajes - BLOQUEA indefinidamente
# (por eso siempre usar after para timeout en pruebas)
IO.puts("receive sin after puede bloquear para siempre!")

# 3. Mailbox muy lleno - puede consumir memoria
# Siempre procesar mensajes o tener logica de limpieza
IO.puts("Monitorear message_queue_len para evitar memory leaks")

# 4. Orden de mensajes entre DOS procesos esta garantizado
# De A a B, mensajes llegan en orden enviado
# Pero entre multiples senders, no hay orden garantizado
IO.puts("Orden garantizado solo entre par de procesos")

# ==========================================
# RESUMEN
# ==========================================

IO.puts("\n=== RESUMEN ===")

IO.puts("""
SEND/RECEIVE:
- send(pid, mensaje): envia mensaje asincrono
- receive do ... end: espera mensaje con pattern matching
- receive after timeout: evita bloqueo infinito

PATRON SERVIDOR:
1. spawn proceso con loop recursivo
2. receive mensajes
3. procesar y responder
4. loop() para seguir escuchando

ESTADO EN SERVIDOR:
- Pasar estado como argumento a loop(estado)
- Cada iteracion puede modificar el estado
- Es la base de GenServer

SIGUIENTE: ver 03_links_monitors.exs
""")
