# gnuplot

## Qué es

`gnuplot` es un programa para hacer gráficos a partir de funciones o de archivos de datos, con un guion de comandos.

## Versión y cómo se ofrece

**Del sistema** (ver [Software disponible](catalogo.md)): viene instalado en todos los nodos, no tienes que instalar nada. Versión: «por confirmar».

Es la versión **sin ventanas**: no abre gráficos en pantalla, los guarda en archivos PNG, PDF o SVG.

## Cómo usarlo

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

Ejecútalo dentro de un trabajo (`~/practica/curva.sh`):

```bash
#!/bin/bash
#SBATCH --job-name=curva
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=%x_%j.out

cd ~/practica
gnuplot curva.gp
```

```bash
cd ~/practica
sbatch curva.sh
```

## Prueba rápida

Un gráfico corto también puedes hacerlo directamente en el nodo de entrada:

```bash
cd ~/practica
gnuplot curva.gp
ls curva.*
```

```text
curva.pdf  curva.png
```

Copia los archivos a tu computador para verlos (ver [Copiar datos](../uso/almacenamiento.md#copiar-datos)).

## Cómo citarlo

«por confirmar»

## Ayuda

- Documentación oficial: [gnuplot.info](http://www.gnuplot.info/documentation.html).
- Dudas: hpc.fisica@usach.cl.
