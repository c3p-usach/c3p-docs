# Contenedores (Pyxis/Enroot)

## ¿Qué es un contenedor?

Un contenedor es un sistema operativo pequeño, empaquetado con un programa y todo lo que ese programa necesita. Lo ejecutas sin instalar nada en el clúster. Una **imagen** es el paquete; un **contenedor** es esa imagen corriendo.

En Chuchunco puedes usar imágenes de Docker Hub, NVIDIA NGC, AMD ROCm o una tuya, en **todos los nodos** (CPU y GPU), sin permisos de administrador. Lo hacen dos programas: **Enroot** (ejecuta la imagen) y **Pyxis** (agrega a `srun` las opciones `--container-*`).

!!! tip "¿Solo necesitas NumPy, SciPy o Matplotlib?"
    No necesitas un contenedor: usa un entorno de Python propio ([Software y Python](software.md)). Los contenedores sirven sobre todo para software pesado o con GPU.

## Las 3 opciones que necesitas

| Opción de `srun` | Para qué |
|---|---|
| `--container-image=<imagen>` | qué imagen usar |
| `--container-mounts=<ruta en el clúster>:<ruta dentro>` | ver tus carpetas dentro del contenedor |
| `--container-save=<archivo>.sqsh` | guardar el contenedor (con lo que instalaste) para reutilizarlo |

Siempre se usan con `srun`, en la línea de comandos o dentro de un script de `sbatch`.

## Tu primer contenedor (CPU)

```bash
srun -p CPU --time=00:10:00 --container-image=ubuntu:24.04 cat /etc/os-release
```

```text
pyxis: importing docker image: ubuntu:24.04
pyxis: imported docker image: ubuntu:24.04
PRETTY_NAME="Ubuntu 24.04.1 LTS"
NAME="Ubuntu"
...
```

La primera vez, Pyxis descarga la imagen; las siguientes veces es más rápido (ver [dónde se guardan](#donde-se-guardan-las-imagenes)).

## Tu primer contenedor con GPU

Pide la GPU con `--gres`, igual que sin contenedor:

=== "NVIDIA (gpun2, gpun3)"
    ```bash
    srun -p GPU --gres=gpu:rtx6000ada:1 --time=00:10:00 \
         --container-image=nvcr.io#nvidia/cuda:12.6.3-base-ubuntu24.04 \
         nvidia-smi -L
    ```

    ```text
    GPU 0: NVIDIA RTX 6000 Ada Generation (UUID: GPU-...)
    ```

=== "AMD (gpun1)"
    ```bash
    srun -p GPU --gres=gpu:mi210:1 --time=00:10:00 \
         --container-image=rocm/pytorch:latest \
         python3 -c "import torch; print(torch.cuda.get_device_name(0))"
    ```

    La imagen de ROCm es grande: la primera descarga puede tardar varios minutos.

Dentro del contenedor ves **solo las GPUs que pediste**.

## Cómo se escribe el nombre de una imagen

| Origen | Ejemplo |
|---|---|
| Docker Hub | `--container-image=python:3.12` |
| NVIDIA NGC | `--container-image=nvcr.io#nvidia/pytorch:24.05-py3` |
| AMD ROCm (Docker Hub) | `--container-image=rocm/pytorch:latest` |
| Archivo `.sqsh` guardado | `--container-image=$HOME/imagenes/mi-imagen.sqsh` |

!!! note "El `#` después del dominio"
    Para registros distintos de Docker Hub se usa `#` entre el dominio y el nombre: `nvcr.io#nvidia/...`, no `nvcr.io/nvidia/...`.

## Ver tus archivos dentro del contenedor

Tu *home* ya se ve dentro del contenedor, en la misma ruta. Para otras carpetas, o para verlas con otro nombre, usa `--container-mounts`, y `--container-workdir` para la carpeta de trabajo:

```bash
srun -p CPU --time=01:00:00 \
     --container-image=python:3.12 \
     --container-mounts=$HOME/datos:/datos \
     --container-workdir=/datos \
     python3 analisis.py
```

Aquí `$HOME/datos` del clúster aparece como `/datos` dentro del contenedor. Lo que el programa escribe en `/datos` queda guardado en `$HOME/datos`.

## Un trabajo por lotes con contenedor

```bash
#!/bin/bash
#SBATCH --job-name=entrenar
#SBATCH -p GPU
#SBATCH --gres=gpu:rtx6000ada:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH --output=%x_%j.out

srun --container-image=nvcr.io#nvidia/pytorch:24.05-py3 \
     --container-workdir=$HOME/mi-modelo \
     python entrenar.py
```

## Agregar tus propios paquetes de Python

Una imagen pública casi nunca trae todo lo que necesitas. Hay dos formas de agregar paquetes.

### Opción A: instalar al inicio de cada trabajo

Simple, pero repite la instalación cada vez:

```bash
srun --container-image=nvcr.io#nvidia/pytorch:24.05-py3 \
     bash -c "pip install --user astropy && python entrenar.py"
```

Sirve para probar. `--user` instala en `~/.local` de tu *home*.

### Opción B: instalar una vez y guardar la imagen (recomendado)

Instala dentro del contenedor y guárdalo como un archivo `.sqsh`. Después usas ese archivo como imagen:

```bash
mkdir -p ~/imagenes

# 1. Instala y guarda (una sola vez)
srun -p CPU --time=01:00:00 \
     --container-image=nvcr.io#nvidia/pytorch:24.05-py3 \
     --container-remap-root \
     --container-save=$HOME/imagenes/pytorch-mio.sqsh \
     pip install astropy

# 2. Úsala todas las veces que quieras
srun -p GPU --gres=gpu:rtx6000ada:1 --time=12:00:00 \
     --container-image=$HOME/imagenes/pytorch-mio.sqsh \
     python entrenar.py
```

- `--container-remap-root` te hace «administrador» **solo dentro del contenedor**, para que `pip` pueda instalar en la imagen.
- El archivo `.sqsh` puede pesar varios GB. Guarda pocos y borra los que no uses.
- Al usar un `.sqsh` no se descarga nada: el trabajo empieza más rápido.

### Tu propia imagen, hecha en tu computador

Si ya usas Docker en tu computador, construye la imagen allí, súbela a un registro (por ejemplo, tu cuenta de Docker Hub) y úsala en el clúster por su nombre:

```bash
# En tu computador
docker build -t tu-usuario-dockerhub/mi-imagen:1.0 .
docker push tu-usuario-dockerhub/mi-imagen:1.0

# En Chuchunco: guárdala como .sqsh para no descargarla cada vez
mkdir -p ~/imagenes
srun -p CPU --time=01:00:00 \
     --container-image=tu-usuario-dockerhub/mi-imagen:1.0 \
     --container-save=$HOME/imagenes/mi-imagen.sqsh \
     true
```

`true` es un comando que no hace nada: aquí solo sirve para descargar la imagen y guardarla.

## ¿Dónde se guardan las imágenes?

- Cuando usas una imagen por su nombre (`python:3.12`), se descarga y se guarda **en el nodo donde corrió, para ti**. La próxima vez que tu trabajo caiga en ese nodo, no se descarga de nuevo. En otro nodo, sí.
- Un archivo `.sqsh` que guardaste en tu *home* se ve desde **todos los nodos**. Por eso conviene para imágenes que usas seguido.
- Carpetas de proyecto compartidas para imágenes (`/data/<grupo>`): por confirmar.

## Errores comunes

| Mensaje o síntoma | Causa probable | Qué hacer |
|---|---|---|
| `invalid image reference` o `No such image` | nombre mal escrito, o `/` en vez de `#` después del dominio | revisa el nombre: `nvcr.io#nvidia/...` |
| `toomanyrequests` | Docker Hub limita las descargas anónimas | guarda la imagen como `.sqsh` (opción B) y úsala desde ahí |
| `Permission denied` al hacer `pip install` dentro del contenedor | dentro de la imagen no eres administrador | usa `--container-remap-root` (opción B) o `pip install --user` (opción A) |
| `nvidia-smi: command not found` o no ve GPUs | no pediste GPU, o la imagen no es para esa GPU | agrega `--gres=gpu:<tipo>:1`; usa imágenes CUDA en `rtx6000ada` y ROCm en `mi210` |
| `No such file or directory` para tus datos | la carpeta no está montada | usa `--container-mounts` o una ruta dentro de tu *home* |
| la primera ejecución tarda mucho | se está descargando la imagen | normal; guarda un `.sqsh` para las siguientes |

## ¿Y si mi software no tiene imagen?

Escríbenos a hpc.fisica@usach.cl indicando el software y la versión, y te ayudamos a encontrar o armar una. Para software con licencia (MATLAB, BIOVIA, etc.) primero revisamos las condiciones de la licencia.
