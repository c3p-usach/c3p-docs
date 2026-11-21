# Compilar tu propio software

Si el programa que necesitas no viene como paquete de Python ni como [imagen de contenedor](contenedores.md), puedes compilarlo tú, en tu propia carpeta y sin permisos de administrador.

## Herramientas disponibles

Desde el 05-11-2026, **todas las máquinas** (nodo de entrada y nodos de cómputo) tienen las mismas herramientas de compilación:

| Herramienta | Comandos |
|---|---|
| Compiladores GCC de Ubuntu 24.04 (C, C++, Fortran) | `gcc`, `g++`, `gfortran` |
| CMake | `cmake` |
| pkg-config | `pkg-config` |
| git | `git` |
| OpenMPI 4.1.6 | `mpicc`, `mpicxx`, `mpif90`, `mpirun` |
| FFTW 3.3.10 | bibliotecas y cabeceras |
| Cabeceras de Python | para compilar extensiones de Python |

No hay sistema de módulos (`module load`): las herramientas están siempre en el `PATH`, no tienes que cargar nada.

## Dónde instalar

| Para quién | Carpeta | Espacio |
|---|---|---|
| Solo para ti | `~/software/<programa>` (tu *home*) | 1 TB |
| Para todo tu grupo | `/data/proyectos/<proyecto>/software/<programa>` | 5 TB (la carpeta del proyecto) |

Ver [Almacenamiento y datos](almacenamiento.md).

## Compila dentro de un trabajo

Compila con `sbatch`, en un nodo de cómputo, **no en el nodo de entrada**. Además de ser un cálculo pesado, hay una razón técnica:

- El nodo de entrada tiene otro procesador (AMD EPYC **Zen 3**) que los nodos de las particiones `CPU` y `MEM` (**Zen 4**).
- Con la opción `-march=native`, el compilador optimiza el programa para el procesador del nodo donde compila. Un programa compilado así en un nodo Zen 4 puede no funcionar en un nodo Zen 3.

Por eso, **compila en la misma partición donde lo vas a ejecutar**:

| Nodos | Procesador |
|---|---|
| `CPU` (`cpun1`–`cpun5`), `MEM` (`high-ram-n1`), `gpun1` | Zen 4 |
| `gpun2`, `gpun3`, nodo de entrada | Zen 3 |

## Ejecutar programas con MPI

Cada trabajo usa **un solo nodo** (ver [Un nodo por trabajo](slurm.md#un-nodo-por-trabajo)). Dentro del trabajo, cualquiera de estas dos formas funciona:

```bash
srun --mpi=pmix ./programa
```

```bash
mpirun -np $SLURM_NTASKS ./programa
```

Pide los procesos MPI con `--ntasks` en el script.

## Ejemplo: LAMMPS

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

### 2. Probar

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

### 3. Ejecutar tu simulación

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

## ¿Algo no compila?

Si un programa no compila, o necesitas una biblioteca que no está instalada, escríbenos a hpc.fisica@usach.cl con el nombre del programa, la versión y el mensaje de error.
