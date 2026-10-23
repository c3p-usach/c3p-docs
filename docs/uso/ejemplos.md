# Ejemplos de trabajos

## Multihilo (OpenMP, NumPy, multiprocessing)

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

## MPI en varios nodos

La forma recomendada es usar un contenedor con tu stack MPI (ver [Contenedores](contenedores.md)):

```bash
#!/bin/bash
#SBATCH -p CPU
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=64
#SBATCH --time=06:00:00

srun --mpi=pmix \
     --container-image=/data/<grupo>/mi-imagen-mpi.sqsh \
     mi_programa_mpi
```

## Mucha memoria

```bash
#!/bin/bash
#SBATCH -p MEM
#SBATCH --cpus-per-task=48
#SBATCH --mem=1000G
#SBATCH --time=2-00:00:00

python3 analisis_grande.py
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

## Ver cuánto usó un trabajo

```bash
seff <jobid>                 # eficiencia de CPU y memoria (por confirmar)
scontrol show job <jobid>
```
