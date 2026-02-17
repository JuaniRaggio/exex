# Concurrencia en Elixir

Este directorio contiene ejemplos didacticos sobre programacion concurrente en Elixir.

## Que es Concurrencia?

Concurrencia es la capacidad de un sistema de manejar multiples tareas que **progresan** simultaneamente. No necesariamente se ejecutan al mismo tiempo (eso es paralelismo), pero el sistema puede alternar entre ellas de forma eficiente.

## El Modelo de Actores

Elixir/Erlang usan el "Actor Model" para concurrencia:

```
+----------+      mensaje      +----------+
| Proceso  | ----------------> | Proceso  |
|    A     |                   |    B     |
+----------+                   +----------+
     |                              |
     v                              v
  Estado                         Estado
  privado                        privado
```

**Caracteristicas:**
- Cada proceso tiene estado privado (aislado)
- Los procesos se comunican solo via mensajes
- No hay memoria compartida
- No hay locks, mutexes, ni semaforos

## Contenido

### 01_intro_processes.exs
Introduccion a los procesos de Elixir:
- Que son los procesos (no son threads del SO)
- PIDs (Process Identifiers)
- spawn para crear procesos
- Aislamiento entre procesos

### 02_send_receive.exs
Comunicacion entre procesos:
- send/2 para enviar mensajes
- receive para recibir y procesar
- Pattern matching en mensajes
- Patron servidor con loop

### 03_links_monitors.exs
Supervision de procesos:
- Links: conexion bidireccional
- Monitors: observacion unidireccional
- trap_exit para manejar fallas
- Reinicio de procesos fallidos

### 04_genserver.exs
GenServer - Abstraccion de servidor:
- Estructura estandar de servidores
- call (sincrono) y cast (asincrono)
- Callbacks: init, handle_call, handle_cast
- Manejo de estado

### 05_agents.exs
Agent - Estado simple:
- Alternativa simple a GenServer
- Solo para mantener estado
- get, update, get_and_update

### 06_tasks.exs
Task - Trabajo asincrono:
- async/await para obtener resultados
- Ejecucion en paralelo
- Timeouts y cancelacion
- Task.Supervisor para produccion

## Como Ejecutar

```bash
# Ejecutar un archivo
elixir 01_intro_processes.exs

# O en IEx para experimentar
iex 01_intro_processes.exs
```

## Conceptos Clave

### Procesos Livianos
Los procesos de Elixir NO son threads del sistema operativo:
- Muy livianos (~2KB de memoria inicial)
- Pueden existir millones simultaneamente
- Scheduling preemptive por la BEAM

### Inmutabilidad + Concurrencia = Seguridad
- Los datos son inmutables
- No hay memoria compartida
- Imposible tener race conditions clasicas

### Let It Crash
Filosofia de Erlang/Elixir:
- No intentar manejar TODOS los errores
- Dejar que los procesos crasheen
- Usar supervisores para reiniciarlos
- Codigo mas limpio y sistemas mas robustos

## Orden de Lectura Sugerido

1. `01_intro_processes.exs` - Entender procesos
2. `02_send_receive.exs` - Comunicacion basica
3. `03_links_monitors.exs` - Supervision
4. `04_genserver.exs` - Patron servidor
5. `05_agents.exs` - Estado simple
6. `06_tasks.exs` - Trabajo asincrono

## Proximos Pasos

- Ver directorio `parallelism/` para ejecucion paralela real
- Aprender sobre OTP y Supervision Trees
- Explorar GenStage para procesamiento de eventos
