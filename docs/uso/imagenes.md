# Imágenes disponibles

En el clúster hay imágenes de contenedor listas para usar y ya probadas en nuestras GPUs. Usarlas es más rápido y liviano que descargar una imagen propia: no se descarga nada y no gastas espacio en tu *home*.

Están en `/data/containers/`, una carpeta por tipo de imagen. Puedes leerlas, pero no modificarlas. Junto a cada imagen hay un archivo `.txt` con su origen, cómo se armó y cómo se probó.

```bash
ls /data/containers/*
```

| Archivo | GPU | Contenido | Origen |
|---|---|---|---|
| `/data/containers/pytorch-cuda/pytorch-cuda-26.09.sqsh` | `rtx6000ada` (`gpun2`, `gpun3`) | PyTorch 2.14 (NVIDIA 26.09), CUDA 13.4, Ubuntu 24.04, Python 3.12 | `nvcr.io/nvidia/pytorch:26.09-py3`, sin modificar |
| `/data/containers/pytorch-rocm/pytorch-rocm-6.4.1-2.6.0.sqsh` | `mi210` (`gpun1`) | PyTorch 2.6.0, ROCm 6.4.1, Ubuntu 24.04, Python 3.12 | `rocm/pytorch:rocm6.4.1_ubuntu24.04_py3.12_pytorch_release_2.6.0`, sin modificar |

Ambas se probaron con 1 GPU: PyTorch ve exactamente la GPU pedida.

## Ejemplo con PyTorch

Pide una GPU del tipo que corresponde a la imagen. Para la prueba bastaron 4 CPUs y 32 GB de memoria.

=== "NVIDIA (gpun2, gpun3)"
    ```bash
    #!/bin/bash
    #SBATCH --job-name=pytorch-cuda
    #SBATCH -p GPU
    #SBATCH --gres=gpu:rtx6000ada:1
    #SBATCH --cpus-per-task=4
    #SBATCH --mem=32G
    #SBATCH --time=02:00:00
    #SBATCH --output=%x_%j.out

    srun --container-image=/data/containers/pytorch-cuda/pytorch-cuda-26.09.sqsh \
         --container-workdir=$HOME/mi-proyecto \
         python mi_script.py
    ```

=== "AMD (gpun1)"
    ```bash
    #!/bin/bash
    #SBATCH --job-name=pytorch-rocm
    #SBATCH -p GPU
    #SBATCH --gres=gpu:mi210:1
    #SBATCH --cpus-per-task=4
    #SBATCH --mem=32G
    #SBATCH --time=02:00:00
    #SBATCH --output=%x_%j.out

    srun --container-image=/data/containers/pytorch-rocm/pytorch-rocm-6.4.1-2.6.0.sqsh \
         --container-workdir=$HOME/mi-proyecto \
         python mi_script.py
    ```

    En las MI210 el código de PyTorch es el mismo que en NVIDIA: se sigue usando `torch.cuda` y `device="cuda"`.

Sin script de `sbatch`, con `srun` directamente:

```bash
srun -p GPU --gres=gpu:rtx6000ada:1 --cpus-per-task=4 --mem=32G \
     --container-image=/data/containers/pytorch-cuda/pytorch-cuda-26.09.sqsh \
     python mi_script.py
```

En `gpun1`, cambia `rtx6000ada` por `mi210` y la imagen por la de ROCm.

!!! note "El trabajo tarda unos minutos en empezar"
    Al inicio de cada trabajo, la imagen se descomprime en el nodo: unos **2 minutos** con la imagen NVIDIA y unos **4 minutos** con la AMD. Es normal; el trabajo no está pegado.

## ¿Cómo se mantienen?

- Se agrega una imagen cuando varios grupos necesitan el mismo software. Para proponer una, escribe a hpc.fisica@usach.cl.
- El nombre del archivo lleva la versión, y un archivo publicado **nunca cambia**: puedes volver a correr tu código con exactamente el mismo software.
- Cuando llega una versión nueva, la anterior se marca «por retirar», con una fecha 6 meses después, y en esa fecha se borra.
- Si necesitas una versión por más tiempo, copia el `.sqsh` a tu propia carpeta y úsala desde ahí:

    ```bash
    mkdir -p ~/imagenes
    cp /data/containers/pytorch-cuda/pytorch-cuda-26.09.sqsh ~/imagenes/
    ```

## ¿Necesitas otra imagen?

Escríbenos a hpc.fisica@usach.cl indicando el software y la versión. También puedes usar o armar tu propia imagen: ver [Contenedores](contenedores.md).
