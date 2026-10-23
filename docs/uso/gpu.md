# GPUs

Chuchunco tiene dos tipos de GPU en la partición `GPU`. Pídelas con `--gres=gpu:<tipo>:<cantidad>`.

| Tipo (`--gres`) | Nodo | GPUs por nodo | Memoria GPU | Ecosistema |
|---|---|---|---|---|
| `rtx6000ada` | `gpun2`, `gpun3` | 4 | 48 GB | NVIDIA CUDA |
| `mi210` | `gpun1` | 2 | 64 GB | AMD ROCm |

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
srun -p GPU --gres=gpu:rtx6000ada:1 nvidia-smi -L
```

## AMD (ROCm)

Las MI210 usan ROCm en lugar de CUDA. PyTorch y TensorFlow tienen versiones ROCm oficiales:

```bash
#!/bin/bash
#SBATCH -p GPU
#SBATCH --gres=gpu:mi210:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00

srun --container-image=rocm/pytorch:latest \
     python entrenar.py
```

Prueba rápida:

```bash
srun -p GPU --gres=gpu:mi210:1 amd-smi list
```

!!! tip "Buenas prácticas"
    - Pide **una GPU** salvo que tu código use varias (DDP, Horovod).
    - Cada nodo NVIDIA tiene solo 24 núcleos para 4 GPUs: pide como máximo **6 CPUs por GPU**.
    - Verifica que tu código efectivamente use la GPU (`nvidia-smi` / `amd-smi` dentro del trabajo).
