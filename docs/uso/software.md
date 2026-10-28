# Software y Python

## Tres formas de tener tu software

| Forma | Para qué | Dónde se explica |
|---|---|---|
| **Tu propio entorno de Python** | NumPy, SciPy, Matplotlib, Astropy y casi cualquier paquete de `pip` | [esta página](#tu-entorno-de-python-paso-a-paso) |
| **Contenedores** | software pesado, con GPU (PyTorch, TensorFlow, CUDA, ROCm), o con muchas dependencias | [Contenedores](contenedores.md) |
| **Lo que ya trae el sistema** | Python 3, `python3-venv` y `gnuplot` (sin ventanas) | [esta página](#gnuplot) |

El clúster **no instala paquetes de Python para todos**. Cada persona crea su propio entorno, con las versiones que necesita. Así un cambio para una persona no rompe el trabajo de otra.

Tampoco hay sistema de módulos (`module load`) por ahora.

No tienes permisos de administrador (`sudo`), y no los necesitas para nada de esta página.

## Tu entorno de Python, paso a paso

Un **entorno virtual** (*venv*) es una carpeta con su propio Python y sus propios paquetes. Lo creas una vez, en tu *home*, y lo usas desde cualquier nodo.

### 1. Créalo

En el nodo de entrada:

```bash
python3 -m venv ~/venvs/ciencia
```

Esto crea la carpeta `~/venvs/ciencia`. Puedes ponerle otro nombre, y tener varios entornos (uno por proyecto, por ejemplo).

### 2. Actívalo

```bash
source ~/venvs/ciencia/bin/activate
```

Tu línea de comandos empieza ahora con `(ciencia)`. Mientras esté activo, `python` y `pip` son los del entorno.

### 3. Instala tus paquetes

```bash
pip install --upgrade pip
pip install numpy scipy matplotlib astropy
```

Tarda uno o dos minutos. Instalar paquetes en el nodo de entrada está bien: es preparar, no calcular.

Comprueba que funcionan:

```bash
python -c "import numpy, scipy, matplotlib, astropy; print('todo bien')"
```

```text
todo bien
```

### 4. Guarda la lista de paquetes (recomendado)

```bash
pip freeze > ~/venvs/ciencia-requisitos.txt
```

Con ese archivo puedes rehacer el entorno igual en otro lugar: `pip install -r ciencia-requisitos.txt`.

### 5. Úsalo en un trabajo

Un programa de ejemplo que calcula y guarda una figura (`~/practica/grafico.py`):

```python
import matplotlib
matplotlib.use("Agg")          # sin pantalla: guarda en archivo
import matplotlib.pyplot as plt
import numpy as np
from astropy import units as u
from scipy import integrate

x = np.linspace(0, 10, 500)
y = np.sin(x) * np.exp(-x / 5)
area, _ = integrate.quad(lambda t: np.sin(t) * np.exp(-t / 5), 0, 10)
distancia = (1 * u.au).to(u.km)

print(f"Área bajo la curva: {area:.4f}")
print(f"1 UA = {distancia:.3e}")

plt.plot(x, y)
plt.xlabel("x")
plt.ylabel("y")
plt.savefig("grafico.png", dpi=150)
print("Figura guardada en grafico.png")
```

El script del trabajo (`~/practica/grafico.sh`) **activa el entorno antes de llamar a Python**:

```bash
#!/bin/bash
#SBATCH --job-name=grafico
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:10:00
#SBATCH --output=%x_%j.out

source ~/venvs/ciencia/bin/activate
cd ~/practica
python grafico.py
```

```bash
cd ~/practica
sbatch grafico.sh
```

Cuando termine:

```bash
cat grafico_*.out
```

```text
Área bajo la curva: 1.0849
1 UA = 1.496e+08 km
Figura guardada en grafico.png
```

Copia la figura a tu computador para verla (desde tu computador):

```bash
scp nombre.apellido@158.170.68.170:practica/grafico.png .
```

!!! tip "Si usas varias CPUs con NumPy"
    NumPy usa varios hilos para álgebra lineal. Dile cuántos tiene con `export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK` en el script, después de activar el entorno.

### Problemas comunes

- **`ModuleNotFoundError: No module named 'numpy'`**: el script no activó el entorno. Revisa la línea `source ~/venvs/ciencia/bin/activate`.
- **`error: externally-managed-environment`** al hacer `pip install`: estás usando el Python del sistema. Activa tu entorno primero.
- **Fuera de un contenedor, no uses `pip install --user`** ni `sudo pip`: instala siempre dentro de tu entorno.

## gnuplot

`gnuplot` está instalado en todos los nodos, en su versión **sin ventanas**: no abre gráficos en pantalla, los guarda en archivos PNG, PDF o SVG.

Ejemplo (`~/practica/curva.gp`):

```gnuplot
set terminal pngcairo size 800,600
set output "curva.png"
set xlabel "x"
set ylabel "sin(x)"
plot sin(x) with lines title "sin(x)"

set terminal pdfcairo
set output "curva.pdf"
replot
```

Ejecútalo dentro de un trabajo, o con un comando corto en el nodo de entrada:

```bash
cd ~/practica
gnuplot curva.gp
ls curva.*
```

```text
curva.pdf  curva.png
```

## ¿Necesitas otro software?

1. Busca si existe una **imagen de contenedor** oficial (Docker Hub, NVIDIA NGC, AMD ROCm): ver [Contenedores](contenedores.md).
2. Si es un paquete de Python, instálalo en tu entorno.
3. Si no encuentras forma, escríbenos a hpc.fisica@usach.cl con el nombre y la versión. Para software con licencia (MATLAB, por ejemplo) primero revisamos las condiciones de la licencia.
