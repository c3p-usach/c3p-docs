# Tu primer trabajo en 15 minutos

Esta página te lleva paso a paso desde conectarte hasta ver los resultados de tu primer trabajo. No necesitas saber Slurm. Copia y pega cada comando.

!!! info "Antes de empezar"
    Necesitas una **cuenta aprobada** en un proyecto ([Solicitar una cuenta](../acceso/solicitar-cuenta.md)) y tu **llave SSH** ([Conectarse por SSH](../acceso/conectarse.md)). Conéctate desde la red cableada USACH o por VPN.

## La idea en 30 segundos

Chuchunco tiene un **nodo de entrada** (`chuchunco`) y varios **nodos de cómputo**. Tú entras al nodo de entrada. Ahí escribes un pequeño archivo, el *script*, que dice qué quieres ejecutar y qué recursos necesitas. Se lo entregas a **Slurm**, el gestor de colas. Slurm lo ejecuta en un nodo de cómputo cuando hay espacio y guarda lo que el programa imprime en un archivo.

No ejecutes cálculos directamente en el nodo de entrada: todo cálculo va por Slurm.

## 1. Conéctate

En tu computador (cambia `nombre.apellido` por tu usuario):

```bash
ssh nombre.apellido@158.170.68.170
```

Si todo va bien, verás un mensaje de bienvenida y una línea que termina en algo como:

```text
nombre.apellido@chuchunco:~$
```

Ya estás en el nodo de entrada.

## 2. Mira a tu alrededor

**¿Qué hay en el clúster?** `sinfo` muestra las particiones (grupos de nodos) y su estado:

```bash
sinfo
```

```text
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
MEM          up 7-00:00:00      1   idle high-ram-n1
CPU*         up 7-00:00:00      5   idle cpun[1-5]
GPU          up 7-00:00:00      3   idle gpun[1-3]
```

- El `*` marca la partición por defecto (`CPU`).
- `TIMELIMIT` es el tiempo máximo de un trabajo: 7 días.
- `STATE` puede ser `idle` (libre), `mix` (en parte ocupado) o `alloc` (lleno).

**¿En qué proyectos estás?** Solo puedes enviar trabajos a nombre de un proyecto aprobado:

```bash
sacctmgr show assoc user=$USER format=account
```

```text
   Account
----------
mi-proyecto
```

Si aparece más de una línea, estás en varios proyectos. Si no aparece ninguna, tu cuenta aún no está asociada a un proyecto: escribe a hpc.fisica@usach.cl.

**¿Dónde estás?** Tu carpeta personal (*home*) es la misma en todos los nodos:

```bash
pwd
```

```text
/home/nombre.apellido
```

## 3. Escribe tu primer script

Crea una carpeta para practicar y entra en ella:

```bash
mkdir -p ~/practica && cd ~/practica
```

Crea el script con el editor `nano`:

```bash
nano hola.sh
```

Pega este contenido:

```bash
#!/bin/bash
#SBATCH --job-name=hola        # nombre del trabajo
#SBATCH --cpus-per-task=1      # 1 CPU
#SBATCH --mem=1G               # 1 GB de memoria
#SBATCH --time=00:05:00        # 5 minutos como máximo
#SBATCH --output=%x_%j.out     # archivo de salida: hola_<número>.out

echo "Hola desde $(hostname)"
echo "Empecé a las $(date)"
sleep 30
echo "Terminé a las $(date)"
```

Guarda con `Ctrl+O` y `Enter`, y sal con `Ctrl+X`.

Las líneas que empiezan con `#SBATCH` le dicen a Slurm qué necesitas. El resto es un script de bash normal.

## 4. Envíalo

```bash
sbatch hola.sh
```

```text
Submitted batch job 1234
```

`1234` es el **número del trabajo** (*job ID*). Anótalo: lo usarás para todo lo demás.

## 5. Míralo en la cola

```bash
squeue -u $USER
```

```text
JOBID PARTITION  NAME     USER ST  TIME NODES NODELIST(REASON)
 1234       CPU  hola nombre.a  R  0:05     1 cpun1
```

- `ST` es el estado: `PD` = pendiente (esperando), `R` = ejecutándose.
- `NODELIST(REASON)` dice en qué nodo corre o, si está pendiente, por qué espera.

Cuando el trabajo termina, desaparece de `squeue`. Este tarda unos 30 segundos.

## 6. Lee el resultado

```bash
cat hola_1234.out
```

```text
Hola desde cpun1
Empecé a las mar 27 oct 2026 15:02:10 -03
Terminé a las mar 27 oct 2026 15:02:40 -03
```

Tu script corrió en `cpun1`, un nodo de cómputo, no en el nodo de entrada. (El nodo, las horas y los números de esta página son de ejemplo: los tuyos serán otros.)

## 7. Revisa qué usó

```bash
sacct -j 1234 -o JobID,Elapsed,MaxRSS,ReqMem,State
```

```text
JobID           Elapsed     MaxRSS     ReqMem      State
------------ ---------- ---------- ---------- ----------
1234           00:00:30                    1G  COMPLETED
1234.batch     00:00:30      1500K             COMPLETED
```

- `Elapsed`: cuánto duró.
- `MaxRSS`: la memoria máxima que usó (en la línea `.batch`).
- `ReqMem`: la memoria que pediste.
- `State`: `COMPLETED` es que terminó bien. `FAILED`, `TIMEOUT` u `OUT_OF_MEMORY` indican un problema (ver [Preguntas frecuentes](../faq.md)).

Usa esto para ajustar tus próximos trabajos: pide un poco más de lo que usaste, no mucho más.

## 8. Ahora con Python

Crea un programa pequeño:

```bash
nano calculo.py
```

```python
import math
import os

n = int(os.environ.get("SLURM_CPUS_PER_TASK", "1"))
print(f"Tengo {n} CPU(s) asignadas")
total = sum(math.sqrt(i) for i in range(10_000_000))
print(f"Suma de raíces: {total:.2f}")
```

Y su script:

```bash
nano calculo.sh
```

```bash
#!/bin/bash
#SBATCH --job-name=calculo
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=00:10:00
#SBATCH --output=%x_%j.out

python3 calculo.py
```

Envíalo y revisa, igual que antes:

```bash
sbatch calculo.sh
squeue -u $USER
cat calculo_*.out
```

```text
Tengo 2 CPU(s) asignadas
Suma de raíces: 21081849486.44
```

Este ejemplo solo usa la biblioteca estándar de Python. Para usar NumPy, SciPy, Matplotlib u otras, crea tu propio entorno: [Software y Python](software.md).

## Si estás en varios proyectos

Elige a qué proyecto se carga el trabajo con `-A`:

```bash
sbatch -A mi-proyecto hola.sh
```

O dentro del script: `#SBATCH -A mi-proyecto`.

## Qué pasa si no pides algo

Si no lo indicas, Slurm usa estos valores:

| Si no pones… | Slurm usa |
|---|---|
| `--partition` | `CPU` |
| `--time` | 4 horas |
| `--mem` | 2,9 GB por CPU en `CPU` · 3,9 GB en `MEM` · 5 GB en `GPU` |

Si tu trabajo pasa del tiempo, Slurm lo detiene (`TIMEOUT`). Si usa más memoria de la que pidió, también lo detiene (`OUT_OF_MEMORY`).

## Siguientes pasos

- [Slurm: colas y límites](slurm.md): particiones, límites, prioridad y por qué un trabajo espera.
- [Software y Python](software.md): instalar tus paquetes.
- [Ejemplos de trabajos](ejemplos.md): multihilo, MPI en un nodo, mucha memoria, arreglos.
- [GPUs](gpu.md) y [Contenedores](contenedores.md).
