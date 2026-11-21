# Cómo conseguir software

Primero revisa [Software disponible](catalogo.md): quizás lo que necesitas ya está, con una receta o una imagen probada en Chuchunco.

Si no está, prueba en este orden:

| Forma | Para qué | Dónde se explica |
|---|---|---|
| **1. Instalarlo tú** | paquetes de Python (NumPy, SciPy, Matplotlib, Astropy y casi cualquier paquete de `pip`) | [Python](python.md) |
| | programas en C, C++ o Fortran, con o sin MPI | [Compilar](compilar.md) |
| | software pesado, con GPU o con muchas dependencias, desde una imagen pública (Docker Hub, NVIDIA NGC, AMD ROCm) o tuya | [Contenedores](contenedores.md) |
| **2. Una imagen compartida** | software ya probado en nuestras GPUs (hoy, PyTorch) | [PyTorch](pytorch.md) |
| **3. EESSI** | biblioteca de software ya compilado | aún no disponible |
| **4. Software con licencia** | MATLAB, por ejemplo | caso a caso: escríbenos (abajo) |

## Sin `sudo` y sin `module load`

- **No tienes permisos de administrador (`sudo`)**, y no los necesitas: instalas en tu propia carpeta (tu *home* o la carpeta de tu proyecto) o usas un contenedor.
- **No hay sistema de módulos (`module load`)**: lo que trae el sistema (Python 3, `python3-venv`, `gnuplot` y las herramientas de compilación) está siempre en el `PATH`, no tienes que cargar nada.
- El clúster **no instala paquetes de Python para todos**: cada persona crea su propio entorno, con las versiones que necesita.

## ¿Necesitas otro software?

Si no encuentras forma de instalarlo, escríbenos a hpc.fisica@usach.cl con el nombre y la versión. Para software con licencia (MATLAB, por ejemplo) primero revisamos las condiciones de la licencia.
