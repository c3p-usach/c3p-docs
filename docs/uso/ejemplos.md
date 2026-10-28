# Ejemplos de trabajos

Todos estos ejemplos cumplen los límites del clúster: **un nodo por trabajo**, **7 días como máximo** y como máximo **512 CPUs y 4 GPUs** en uso por persona (ver [Slurm: colas y límites](slurm.md)). Cambia los recursos según lo que use tu programa.

## Multihilo (OpenMP, NumPy, multiprocessing)

Un proceso que usa varias CPUs:

```bash
#!/bin/bash
#SBATCH -p CPU
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=12:00:00

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
./mi_programa
```

## MPI en un nodo

Varios procesos MPI, todos en el mismo nodo. Un nodo `CPU` tiene 256 CPUs. La forma recomendada es usar un contenedor con tu programa MPI (ver [Contenedores](contenedores.md)):

```bash
#!/bin/bash
#SBATCH -p CPU
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=06:00:00

srun --mpi=pmix \
     --container-image=$HOME/imagenes/mi-imagen-mpi.sqsh \
     mi_programa_mpi
```

`srun` lanza los 64 procesos. No uses `mpirun` dentro del script.

!!! info "¿Necesitas más de un nodo?"
    Por defecto, cada trabajo usa un solo nodo, y un trabajo con `--nodes=2` o más se rechaza. Si tu programa de verdad necesita varios nodos, el o la responsable de tu proyecto puede pedirlo a hpc.fisica@usach.cl. Si se aprueba, se agrega `#SBATCH --qos=multinodo` al script. Ver [Un nodo por trabajo](slurm.md#un-nodo-por-trabajo).

## Mucha memoria

La partición `MEM` tiene un nodo con 1,5 TB de RAM:

```bash
#!/bin/bash
#SBATCH -p MEM
#SBATCH --cpus-per-task=48
#SBATCH --mem=1000G
#SBATCH --time=2-00:00:00

python3 analisis_grande.py
```

## Con GPU

Ver [GPUs](gpu.md). Un ejemplo corto:

```bash
#!/bin/bash
#SBATCH -p GPU
#SBATCH --gres=gpu:rtx6000ada:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00

srun --container-image=nvcr.io#nvidia/pytorch:24.05-py3 python entrenar.py
```

## Arreglo de trabajos (barrido de parámetros)

Lanza 100 trabajos independientes, cada uno con un índice distinto:

```bash
#!/bin/bash
#SBATCH -p CPU
#SBATCH --array=1-100%20        # máximo 20 a la vez
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%A_%a.out

python3 simular.py --semilla $SLURM_ARRAY_TASK_ID
```

- `%A` es el número del arreglo y `%a` el índice de cada trabajo.
- Crea la carpeta `logs` antes de enviarlo: `mkdir -p logs`.
- Cada trabajo del arreglo cuenta para tu límite de 512 CPUs. Aquí, 20 a la vez × 2 CPUs = 40 CPUs.

## Trabajos más largos que 7 días

Ningún trabajo puede pasar de 7 días. Si tu cálculo dura más, haz que guarde su avance cada cierto tiempo (*checkpoint*) y que pueda continuar desde ahí. Luego encadena trabajos:

```bash
primero=$(sbatch --parsable parte1.sh)
sbatch --dependency=afterok:$primero parte2.sh
```

El segundo empieza solo cuando el primero termina bien.

## Ver cuánto usó un trabajo

```bash
sacct -j <jobid> -o JobID,Elapsed,MaxRSS,ReqMem,State
scontrol show job <jobid>       # mientras está en cola o corriendo
```

`MaxRSS` es la memoria máxima que usó; `ReqMem`, la que pediste. Si `State` dice `OUT_OF_MEMORY`, pide más memoria.
