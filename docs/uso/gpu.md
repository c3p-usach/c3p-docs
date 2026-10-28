# GPUs

Chuchunco tiene 12 GPUs de dos tipos en la partición `GPU`. Pídelas con `--gres=gpu:<tipo>:<cantidad>`. Tu trabajo ve **solo las GPUs que pidió**.

Cada persona puede tener como máximo **4 GPUs** en uso al mismo tiempo; los trabajos que pasen de eso esperan en la cola (ver [Slurm: colas y límites](slurm.md#quien-va-primero-prioridad-y-limites)).

| Tipo (`--gres`) | Nodo | GPUs por nodo | Memoria GPU | Ecosistema |
|---|---|---|---|---|
| `rtx6000ada` | `gpun2`, `gpun3` | 4 | 48 GB | NVIDIA CUDA |
| `mi210` | `gpun1` | 4 | 64 GB | AMD ROCm |

## NVIDIA (CUDA)

```bash
#!/bin/bash
#SBATCH -p GPU
#SBATCH --gres=gpu:rtx6000ada:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00

srun --container-image=nvcr.io#nvidia/pytorch:24.05-py3 \
     python entrenar.py
```

Prueba rápida:

```bash
srun -p GPU --gres=gpu:rtx6000ada:1 --time=00:05:00 nvidia-smi -L
```

## AMD (ROCm)

Las MI210 usan ROCm en lugar de CUDA. PyTorch y TensorFlow tienen versiones ROCm oficiales. Los contenedores ROCm funcionan en las MI210: ver la pestaña «AMD (gpun1)» en [Tu primer contenedor con GPU](contenedores.md#tu-primer-contenedor-con-gpu).

Prueba rápida:

```bash
srun -p GPU --gres=gpu:mi210:1 --time=00:05:00 rocm-smi --showbus
```

!!! tip "Buenas prácticas"
    - Pide **una GPU** salvo que tu código use varias (DDP, Horovod).
    - Cada nodo NVIDIA tiene 48 CPUs para 4 GPUs: pide como máximo **12 CPUs por GPU**, para no dejar GPUs sin CPUs. En `gpun1` (MI210) son 64 CPUs: hasta **16 CPUs por GPU**.
    - Memoria por defecto en `GPU`: 5 GB por CPU. Si necesitas más, usa `--mem`.
    - Verifica que tu código efectivamente use la GPU (`nvidia-smi` / `rocm-smi` dentro del trabajo).
