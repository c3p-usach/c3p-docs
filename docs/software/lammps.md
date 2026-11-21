# LAMMPS

## Qué es

LAMMPS es un programa de dinámica molecular, muy usado en ciencia de materiales, física de la materia blanda y química. Se distribuye como código fuente y se compila con los paquetes que necesitas.

## Versión y cómo se ofrece

**Receta para compilar · Soporte: Probado** (ver [Software disponible](catalogo.md)). C3P probó estas recetas en Chuchunco; tú compilas y ejecutas LAMMPS en tu propia carpeta.

| Dónde corre | Cómo | Versión |
|---|---|---|
| CPU (particiones `CPU` y `MEM`) | lo compilas tú (abajo) | rama `stable` de LAMMPS |
| GPU AMD MI210 (`gpun1`) | lo compilas tú, con KOKKOS (ver [GPU (KOKKOS)](#gpu-kokkos)) | rama `release` de LAMMPS |
| GPU NVIDIA RTX 6000 Ada (`gpun2`, `gpun3`) | imagen lista de NVIDIA, con KOKKOS (ver [GPU (KOKKOS)](#gpu-kokkos)) | `stable_22Jul2025` |

## Cómo usarlo

### 1. Compilar

Este script descarga la versión estable de LAMMPS, la compila en un nodo de la partición `CPU` e instala el programa en `$PREFIX/bin/lmp`. Guárdalo como `compilar-lammps.sbatch` y envíalo con `sbatch compilar-lammps.sbatch`.

```bash
#!/bin/bash
# Build LAMMPS (stable branch) in your own folder, on a CPU node (AMD EPYC Zen 4).
# Use: sbatch compilar-lammps.sbatch      Result: $PREFIX/bin/lmp
#SBATCH --job-name=compilar-lammps
#SBATCH --partition=CPU
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=32G
#SBATCH --time=01:00:00
#SBATCH --output=compilar-lammps-%j.out
set -euo pipefail

PREFIX=$HOME/software/lammps-stable     # for a group install: /data/proyectos/<proyecto>/software/lammps-stable
SRC=$HOME/src

mkdir -p "$SRC" && cd "$SRC"
[ -d lammps ] || git clone --depth 1 --branch stable https://github.com/lammps/lammps.git
cd lammps
git log -1 --format='LAMMPS commit %h %cd'
rm -rf build && mkdir build && cd build

# Packages: add -D PKG_<NAME>=yes for each one you need (list: lmp -h after building, or docs.lammps.org/Packages_list.html)
cmake ../cmake \
  -D CMAKE_INSTALL_PREFIX="$PREFIX" \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_CXX_FLAGS="-O3 -march=native" \
  -D BUILD_MPI=yes -D BUILD_OMP=yes -D FFT=FFTW3 \
  -D PKG_MOLECULE=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_RIGID=yes \
  -D PKG_EXTRA-PAIR=yes -D PKG_OPENMP=yes

cmake --build . -j "$SLURM_CPUS_PER_TASK"
cmake --install .
"$PREFIX/bin/lmp" -h | grep -A8 '^Installed packages'
echo "OK: $PREFIX/bin/lmp"
# -march=native makes a binary for the node it was built on (Zen 4: CPU and MEM partitions, gpun1).
# For gpun2/gpun3 (Zen 3), build there or remove -march=native.
```

Qué puedes cambiar:

- **`PREFIX`**: dónde queda instalado LAMMPS. Por defecto, en tu *home*. Para que lo use todo tu grupo, cámbialo a `/data/proyectos/<proyecto>/software/lammps-stable`.
- **Paquetes**: agrega `-D PKG_<NOMBRE>=yes` en la línea de `cmake` por cada paquete que necesites. La lista está en [docs.lammps.org/Packages_list.html](https://docs.lammps.org/Packages_list.html).
- **Otra versión**: en vez de `--branch stable`, usa una de las etiquetas de [github.com/lammps/lammps/tags](https://github.com/lammps/lammps/tags), por ejemplo `--branch <etiqueta>`.
- **Para `gpun2` o `gpun3`** (Zen 3): compila en esos nodos, o quita `-march=native`.

Al terminar, el archivo `compilar-lammps-<jobid>.out` muestra los paquetes instalados y termina con `OK: .../bin/lmp`.

### 2. Ejecutar tu simulación

```bash
#!/bin/bash
#SBATCH --job-name=lammps
#SBATCH --partition=CPU
#SBATCH --nodes=1
#SBATCH --ntasks=64
#SBATCH --time=1-00:00:00
#SBATCH --output=%x_%j.out

srun --mpi=pmix $HOME/software/lammps-stable/bin/lmp -in in.tu_archivo
```

Cambia `in.tu_archivo` por tu archivo de entrada y envía el script desde la carpeta donde está ese archivo.

!!! tip "Encadenar compilación y simulación"
    Envía la simulación cuando la compilación haya terminado. O envíala de inmediato, para que espere a que la compilación termine bien:

    ```bash
    sbatch compilar-lammps.sbatch               # responde: Submitted batch job <jobid>
    sbatch --dependency=afterok:<jobid> lammps.sbatch
    ```

!!! tip "Si el nodo falla, el trabajo empieza de nuevo"
    Si el nodo donde corre tu simulación falla, Slurm la vuelve a poner en la cola y empieza **desde el principio**. Guarda el avance con `restart` en tu archivo de entrada y continúa con `read_restart`. Ver [Si un nodo falla](../uso/slurm.md#si-un-nodo-falla-tu-trabajo-vuelve-a-empezar).

## Prueba rápida

Este script corre el ejemplo «melt» que trae LAMMPS, con `mpirun` y con `srun --mpi=pmix`, para comprobar que la compilación funciona:

```bash
#!/bin/bash
# Run the LAMMPS "melt" example two ways (mpirun and srun --mpi=pmix) to check the build.
#SBATCH --job-name=prueba-lammps
#SBATCH --partition=CPU
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=00:10:00
#SBATCH --output=prueba-lammps-%j.out
set -uo pipefail
LMP=$HOME/software/lammps-stable/bin/lmp
cd "$HOME/src/lammps/examples/melt"
echo "== mpirun";        mpirun -np "$SLURM_NTASKS" "$LMP" -in in.melt -log none | grep -E 'Loop time|Total wall|ERROR'
echo "== srun pmix";     srun --mpi=pmix "$LMP" -in in.melt -log none | grep -E 'Loop time|Total wall|ERROR'
```

Si las dos partes muestran `Loop time` y `Total wall time`, sin `ERROR`, LAMMPS está listo.

## GPU (KOKKOS)

Hay dos tipos de GPU y una forma de usar cada uno, las dos con el paquete KOKKOS de LAMMPS:

| GPU | Nodo | Cuándo conviene | Cómo |
|---|---|---|---|
| AMD MI210 | `gpun1`, 4 GPUs | doble precisión: es fuerte en doble precisión | compilas tu propio LAMMPS con `hipcc` de ROCm (ya instalado en `gpun1`) |
| NVIDIA RTX 6000 Ada | `gpun2`, `gpun3`, 4 GPUs cada uno | rápida en precisión simple o mixta, lenta en doble | usas la imagen lista de NVIDIA `nvcr.io/nvidia/lammps:stable_22Jul2025` |

En las dos:

- Lanza siempre con **`srun --mpi=pmix`**. Sin eso, MPI falla al empezar con `OPAL ERROR: Unreachable`.
- Usa **un proceso MPI por GPU**: `--ntasks` igual al número de GPUs que pides.
- Agrega `-k on g <GPUs> -sf kk` a `lmp`.

### AMD MI210 (`gpun1`)

**1. Compilar** (una vez). Guárdalo como `compilar-lammps-kokkos-mi210.sbatch` y envíalo con `sbatch compilar-lammps-kokkos-mi210.sbatch`. Al final corre el ejemplo «melt» en 1 GPU, como prueba:

```bash
#!/bin/bash
# Build LAMMPS with KOKKOS for the AMD MI210 GPUs (gpun1), using the ROCm already installed there.
# Use: sbatch compilar-lammps-kokkos-mi210.sbatch      Result: $PREFIX/bin/lmp
#SBATCH --job-name=lammps-kk-mi210
#SBATCH --partition=GPU
#SBATCH --nodelist=gpun1
#SBATCH --gres=gpu:mi210:1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G
#SBATCH --time=01:30:00
#SBATCH --output=lammps-kk-mi210-%j.out
set -euo pipefail

PREFIX=$HOME/software/lammps-kokkos-mi210   # group install: /data/proyectos/<proyecto>/software/...
SRC=$HOME/src/lammps-release
export PATH=/opt/rocm/bin:$PATH
export CXX=/opt/rocm/bin/hipcc   # KOKKOS for AMD GPUs must be compiled with ROCm's hipcc, not /usr/bin/c++

[ -d "$SRC" ] || git clone --depth 1 --branch release https://github.com/lammps/lammps.git "$SRC"
cd "$SRC"; git log -1 --format='LAMMPS commit %h %cd'
rm -rf build-kk-mi210 && mkdir build-kk-mi210 && cd build-kk-mi210

# basic.cmake = KSPACE MANYBODY MOLECULE RIGID; add -D PKG_<NAME>=yes for more.
# kokkos-hip.cmake already targets the MI210 (Kokkos_ARCH_VEGA90A = gfx90a); don't add another GPU arch.
cmake ../cmake \
  -C ../cmake/presets/basic.cmake \
  -C ../cmake/presets/kokkos-hip.cmake \
  -D CMAKE_CXX_COMPILER=/opt/rocm/bin/hipcc \
  -D CMAKE_INSTALL_PREFIX="$PREFIX" \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_INSTALL_RPATH='/opt/rocm/llvm/lib;/opt/rocm/lib' \
  -D BUILD_MPI=yes

cmake --build . -j "$SLURM_CPUS_PER_TASK"
cmake --install .
"$PREFIX/bin/lmp" -h | grep -A8 '^Installed packages'

echo "== test: melt example on 1 MI210"
cd "$SRC/examples/melt"
export LD_LIBRARY_PATH=/opt/rocm/llvm/lib:/opt/rocm/lib:${LD_LIBRARY_PATH:-}   # only needed for builds without the RPATH line
srun --mpi=pmix -n 1 "$PREFIX/bin/lmp" -k on g 1 -sf kk -in in.melt -log none | grep -E 'KOKKOS|Loop time|ERROR|WARNING' || true
```

**2. Ejecutar tu simulación** (`ejecutar-lammps-mi210.sbatch`, desde la carpeta de tu archivo de entrada):

```bash
#!/bin/bash
# LAMMPS with KOKKOS on the AMD MI210 GPUs (node gpun1, 4 GPUs). Build first with compilar-lammps-kokkos-mi210.sbatch.
#SBATCH --job-name=lammps-mi210
#SBATCH --partition=GPU
#SBATCH --nodelist=gpun1
#SBATCH --gres=gpu:mi210:4          # 1 to 4 GPUs; keep ntasks = number of GPUs
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --output=lammps-mi210-%j.out
LMP=$HOME/software/lammps-kokkos-mi210/bin/lmp
export LD_LIBRARY_PATH=/opt/rocm/llvm/lib:/opt/rocm/lib:${LD_LIBRARY_PATH:-}
srun --mpi=pmix "$LMP" -k on g "$SLURM_NTASKS" -sf kk -in in.tu_archivo
```

### NVIDIA RTX 6000 Ada (`gpun2`, `gpun3`)

**1. Guardar la imagen** en la carpeta de tu proyecto (una vez; unos 2 GB). Cambia `PROYECTO` por el nombre de tu proyecto, guárdalo como `importar-imagen-lammps.sbatch` y envíalo con `sbatch importar-imagen-lammps.sbatch`:

```bash
#!/bin/bash
# Download NVIDIA's LAMMPS image once and save it as one file in your project folder (~2 GB, 5-10 min).
# Use: edit PROYECTO, then  sbatch importar-imagen-lammps.sbatch
#SBATCH --job-name=importar-lammps
#SBATCH --partition=CPU
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=00:30:00
#SBATCH --output=importar-lammps-%j.out
set -euo pipefail
PROYECTO=mi-proyecto
DEST=/data/proyectos/$PROYECTO/containers
mkdir -p "$DEST"
enroot import -o "$DEST/lammps-stable_22Jul2025.sqsh" 'docker://nvcr.io#nvidia/lammps:stable_22Jul2025'
ls -lh "$DEST/lammps-stable_22Jul2025.sqsh"
```

**2. Ejecutar tu simulación** (`ejecutar-lammps-rtx.sbatch`, desde la carpeta de tu archivo de entrada; cambia `PROYECTO` aquí también):

```bash
#!/bin/bash
# LAMMPS with KOKKOS on the NVIDIA RTX 6000 Ada GPUs (gpun2, gpun3; 4 GPUs each), using NVIDIA's ready-made image.
# First, once: sbatch importar-imagen-lammps.sbatch  (saves the image in your project folder)
#SBATCH --job-name=lammps-rtx
#SBATCH --partition=GPU
#SBATCH --gres=gpu:rtx6000ada:4     # 1 to 4 GPUs; keep ntasks = number of GPUs
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --output=lammps-rtx-%j.out
PROYECTO=mi-proyecto
IMG=/data/proyectos/$PROYECTO/containers/lammps-stable_22Jul2025.sqsh
# $(pwd -P) = the real folder (/data/proyectos/...): inside the container /home/proyectos/... does not exist.
# Output goes next to this script; a folder like log/ must be writable by your project group (chmod g+w log).
# The image has one LAMMPS per GPU generation; sm86 is the one that runs on the RTX 6000 Ada (sm89).
srun --mpi=pmix --container-image="$IMG" --container-workdir="$(pwd -P)" bash -c '
  d=/usr/local/lammps/sm86; export LD_LIBRARY_PATH=$d/lib:$LD_LIBRARY_PATH
  $d/bin/lmp -k on g $SLURM_NTASKS -sf kk -in in.tu_archivo'
```

El contenedor empieza en `--container-workdir="$(pwd -P)"` porque en Chuchunco `/home/proyectos` y `/data/proyectos` son la misma carpeta, pero dentro de un contenedor solo existen `/data/proyectos` (y tu *home*): `pwd -P` da la ruta real.

- LAMMPS avisa que no está compilado para esta tarjeta exacta (usa la versión `sm86`). Funciona.
- La imagen corre en **doble precisión** y trae un conjunto fijo de paquetes: `lmp -h` los lista. Si necesitas otros paquetes, o precisión mixta en las RTX, escribe a hpc.fisica@usach.cl.

## Cómo citarlo

«por confirmar»

## Ayuda

- Documentación oficial: [docs.lammps.org](https://docs.lammps.org/).
- Si algo no compila o no corre, escríbenos a hpc.fisica@usach.cl con el script que usaste y el archivo `.out` del trabajo.
