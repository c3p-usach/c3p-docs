# Primeros pasos con Slurm

Slurm es el gestor de colas: tú describes qué recursos necesita tu trabajo y Slurm lo ejecuta en los nodos de cómputo cuando esos recursos están libres.

## Particiones

| Partición | Nodos | Para qué | Tiempo máximo |
|---|---|---|---|
| `CPU` | `cpun[1-5]` | trabajos CPU generales, MPI | por confirmar |
| `MEM` | `high-ram-n1` | trabajos que necesitan mucha RAM (hasta 1,5 TB) | por confirmar |
| `GPU` | `gpun[1-3]` | trabajos con GPU (NVIDIA o AMD) | por confirmar |
| `ALL` *(por defecto)* | todos | — | por confirmar |

!!! tip "Indica siempre la partición"
    Si no indicas `--partition`, el trabajo va a `ALL` y puede caer en un nodo GPU, ocupándolo sin usar sus GPUs. Usa `-p CPU` para trabajos solo-CPU.

## Comandos básicos

| Comando | Qué hace |
|---|---|
| `sinfo` | estado de particiones y nodos |
| `sbatch script.sh` | envía un trabajo por lotes |
| `squeue -u $USER` | tus trabajos en cola o ejecutándose |
| `scancel <jobid>` | cancela un trabajo |
| `scontrol show job <jobid>` | detalle de un trabajo (por qué está pendiente, dónde corre) |
| `srun --pty bash` | sesión interactiva en un nodo de cómputo |

## Tu primer trabajo

Crea `prueba.sh`:

```bash
#!/bin/bash
#SBATCH --job-name=prueba
#SBATCH --partition=CPU
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=%x_%j.out

echo "Corriendo en $(hostname) con $SLURM_CPUS_PER_TASK núcleos"
python3 mi_script.py
```

Envíalo y revisa:

```bash
sbatch prueba.sh          # responde: Submitted batch job 1234
squeue -u $USER           # PD = pendiente, R = ejecutándose
cat prueba_1234.out       # salida cuando termina
```

## Sesión interactiva

Para pruebas cortas, compilar o depurar en un nodo de cómputo:

```bash
srun -p CPU --cpus-per-task=4 --mem=8G --time=00:30:00 --pty bash
```

Sal con `exit` para liberar el nodo.

## Opciones `#SBATCH` más usadas

| Opción | Significado |
|---|---|
| `--partition=CPU` | partición |
| `--nodes=1` | número de nodos: **cada trabajo usa un solo nodo** (ver abajo) |
| `--ntasks=64` | número de procesos (MPI) |
| `--cpus-per-task=8` | hilos por proceso (OpenMP, Python multiproceso) |
| `--mem=32G` | memoria por nodo |
| `--gres=gpu:rtx6000ada:1` | GPUs (ver [GPUs](gpu.md)) |
| `--time=1-12:00:00` | tiempo máximo (días-hh:mm:ss) |
| `--array=1-100` | arreglo de trabajos |
| `--mail-type=END,FAIL` y `--mail-user=tu@usach.cl` | aviso por correo (por confirmar) |

!!! note "Un nodo por trabajo"
    En Chuchunco cada trabajo corre en **un solo nodo** (`MaxNodes=1` en las particiones `CPU`, `MEM` y `GPU`). Un nodo de cómputo ya tiene 256 hilos (`CPU`) o 4 GPUs (`GPU`), y la red entre nodos no está pensada para cálculos muy acoplados entre máquinas. MPI dentro de un nodo funciona normalmente.

    Si tu proyecto realmente necesita varios nodos, escríbenos explicando por qué. Si se aprueba, habilitamos la opción para la cuenta Slurm de tu proyecto y envías con `--qos=multinodo --nodes=N`.

Más ejemplos en [Ejemplos de trabajos](ejemplos.md).
