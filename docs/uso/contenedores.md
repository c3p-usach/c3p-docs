# Contenedores (Pyxis/Enroot)

En Chuchunco el software se usa principalmente mediante **contenedores**: tomas una imagen Docker (de Docker Hub, NVIDIA NGC, AMD/ROCm o una propia) y Slurm la ejecuta directamente en los nodos, sin necesidad de permisos de administrador.

Esto lo hacen dos componentes de NVIDIA: **Enroot** (convierte imágenes Docker en archivos `.sqsh` y las ejecuta sin root) y **Pyxis** (agrega a `srun` las opciones `--container-*`).

## Usar una imagen pública

```bash
srun -p CPU --container-image=ubuntu:22.04 cat /etc/os-release
```

Sintaxis de imágenes:

| Origen | Ejemplo |
|---|---|
| Docker Hub | `--container-image=python:3.12` |
| NVIDIA NGC | `--container-image=nvcr.io#nvidia/pytorch:24.05-py3` |
| ROCm (AMD) | `--container-image=rocm/pytorch:latest` |
| Archivo local | `--container-image=/data/<grupo>/mi-imagen.sqsh` |

!!! note "Registro con `#`"
    Para registros distintos de Docker Hub se usa `#` en lugar de `/` después del dominio: `nvcr.io#nvidia/...`.

## Montar tus datos dentro del contenedor

```bash
srun -p CPU \
     --container-image=python:3.12 \
     --container-mounts=/data/<grupo>:/datos \
     --container-workdir=/datos \
     python3 analisis.py
```

## Guardar la imagen para no descargarla cada vez

Importar una imagen grande toma minutos. Conviértela una vez a `.sqsh` y reutilízala:

```bash
srun -p CPU enroot import -o /data/<grupo>/pytorch.sqsh docker://nvcr.io#nvidia/pytorch:24.05-py3
srun -p GPU --gres=gpu:rtx6000ada:1 --container-image=/data/<grupo>/pytorch.sqsh python entrenar.py
```

## Tu propia imagen

Construye la imagen en tu computador con Docker, expórtala y conviértela en el clúster:

```bash
# En tu computador
docker build -t mi-imagen:1.0 .
docker save mi-imagen:1.0 -o mi-imagen.tar
scp mi-imagen.tar chuchunco:/data/<grupo>/

# En Chuchunco
srun -p CPU enroot import -o /data/<grupo>/mi-imagen.sqsh /data/<grupo>/mi-imagen.tar
```

## ¿Y si mi software no tiene imagen?

Escríbenos a hpc.fisica@usach.cl indicando el software y la versión. Podemos preparar una imagen o un módulo para todos los usuarios. Para software con licencia (MATLAB, BIOVIA, etc.) necesitamos verificar primero las condiciones de la licencia.
