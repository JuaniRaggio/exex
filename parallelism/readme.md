# Paralelismo en Elixir

Este directorio contiene ejemplos sobre programacion paralela en Elixir.

## Concurrencia vs Paralelismo

```
CONCURRENCIA                          PARALELISMO
(estructura)                          (ejecucion)

   Tarea A                             Core 1    Core 2    Core 3
      |                                  |         |         |
   Tarea B       <- alternando ->     Tarea A   Tarea B   Tarea C
      |                                  |         |         |
   Tarea A                               v         v         v
      |                               ejecutando AL MISMO TIEMPO
      v
  una a la vez
```

- **Concurrencia**: multiples tareas en progreso (pueden alternarse)
- **Paralelismo**: multiples tareas ejecutandose al mismo tiempo

Elixir soporta ambos de forma nativa.

## Como Elixir Logra Paralelismo

La BEAM (maquina virtual de Erlang/Elixir) usa:

1. **Schedulers**: Tipicamente uno por core del CPU
2. **Procesos livianos**: Distribuidos entre schedulers
3. **Preemption**: Ningun proceso monopoliza el CPU

```
+-----------+     +-----------+     +-----------+
| Scheduler |     | Scheduler |     | Scheduler |
|    #1     |     |    #2     |     |    #3     |
+-----+-----+     +-----+-----+     +-----+-----+
      |                 |                 |
  +---+---+         +---+---+         +---+---+
  |  P1   |         |  P3   |         |  P5   |
  |  P2   |         |  P4   |         |  P6   |
  +-------+         +-------+         +-------+
```

## Contenido

### 01_intro_parallelism.exs
Fundamentos del paralelismo:
- Schedulers de la BEAM
- Demostracion de paralelismo real
- Cuando el paralelismo ayuda (y cuando no)
- Overhead de crear procesos

### 02_parallel_patterns.exs
Patrones comunes de paralelismo:
- Map paralelo
- Filter paralelo
- Reduce paralelo (divide and conquer)
- Producer-Consumer
- Scatter-Gather
- Pipeline paralelo
- Timeout y fallback
- Race (primer resultado gana)

### 03_flow_intro.exs
Introduccion a Flow:
- Enum vs Stream vs Flow
- Particionamiento automatico
- Cuando usar Flow
- Ejemplos conceptuales

## Herramientas para Paralelismo

### Task.async_stream (incluido en Elixir)
```elixir
items
|> Task.async_stream(fn item -> procesar(item) end, max_concurrency: 4)
|> Enum.to_list()
```

### Flow (libreria externa)
```elixir
# mix.exs: {:flow, "~> 1.2"}

data
|> Flow.from_enumerable()
|> Flow.map(&procesar/1)
|> Enum.to_list()
```

### GenStage (libreria externa)
Para pipelines con backpressure (control de flujo).

### Broadway (libreria externa)
Para procesamiento de eventos/mensajes a escala.

## Reglas de Oro

1. **No paralelizar trabajo trivial**
   - El overhead supera el beneficio
   - Regla: si tarda < 1ms, probablemente no vale la pena

2. **Controlar concurrencia**
   - Usar `max_concurrency` para limitar procesos simultaneos
   - Evitar saturar recursos (conexiones DB, APIs)

3. **Medir antes de optimizar**
   - Paralelizar no siempre es mas rapido
   - Hacer benchmarks con datos reales

4. **Considerar el cuello de botella**
   - Si hay un recurso compartido limitado, paralelizar no ayuda
   - Ejemplo: una sola conexion a base de datos

## Como Ejecutar

```bash
# Ejecutar un archivo
elixir 01_intro_parallelism.exs

# En IEx para experimentar
iex 01_intro_parallelism.exs
```

## Recursos Adicionales

- [Elixir Task documentation](https://hexdocs.pm/elixir/Task.html)
- [Flow library](https://hexdocs.pm/flow)
- [GenStage](https://hexdocs.pm/gen_stage)
- [Broadway](https://hexdocs.pm/broadway)
