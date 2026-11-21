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

Ver [Almacenamiento y datos](../uso/almacenamiento.md).

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

Cada trabajo usa **un solo nodo** (ver [Un nodo por trabajo](../uso/slurm.md#un-nodo-por-trabajo)). Dentro del trabajo, cualquiera de estas dos formas funciona:

```bash
srun --mpi=pmix ./programa
```

```bash
mpirun -np $SLURM_NTASKS ./programa
```

Pide los procesos MPI con `--ntasks` en el script.

## ¿Algo no compila?

Si un programa no compila, o necesitas una biblioteca que no está instalada, escríbenos a hpc.fisica@usach.cl con el nombre del programa, la versión y el mensaje de error.

## Recetas probadas

Para programas concretos, con scripts listos para copiar (por ejemplo, [LAMMPS](lammps.md)), ver [Software disponible](catalogo.md).
