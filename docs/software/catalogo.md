# Software disponible

| Software | Versión | Cómo se ofrece | Soporte | Página |
|---|---|---|---|---|
| PyTorch | 2.14 (NVIDIA) · 2.6.0 (AMD) | imagen compartida | Mantenido | [PyTorch](pytorch.md) |
| LAMMPS | rama `stable` (CPU) · rama `release` (MI210) · `stable_22Jul2025` (RTX 6000 Ada) | receta para compilar (CPU, MI210) · imagen de NVIDIA (RTX 6000 Ada) | Probado | [LAMMPS](lammps.md) |
| gnuplot | «por confirmar» | del sistema | — | [gnuplot](gnuplot.md) |
| GCC (C, C++, Fortran), CMake, OpenMPI, FFTW | GCC 13 · CMake «por confirmar» · OpenMPI 4.1.6 · FFTW 3.3.10 | del sistema | — | [Compilar](compilar.md) |
| NumPy, SciPy, Matplotlib, Astropy y otros paquetes de Python | la que instales | tu entorno de Python | — | [Python](python.md) |

- **Mantenido**: C3P lo mantiene funcionando y actualizado (por ejemplo, una imagen compartida).
- **Probado**: C3P probó la receta una vez en Chuchunco; tú lo compilas y lo ejecutas.

Lo «del sistema» viene instalado en todas las máquinas. Tu entorno de Python lo mantienes tú.

¿No está lo que buscas? Ver [Cómo conseguir software](index.md).
