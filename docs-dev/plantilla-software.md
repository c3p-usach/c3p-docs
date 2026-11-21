<!--
Plantilla para una página de programa en docs/software/<programa>.md.

Cómo usarla:
1. Copia este archivo a docs/software/<programa>.md (nombre en minúsculas, sin espacios).
2. Agrégala al nav de mkdocs.yml, en la sección Software, después de «Software disponible».
3. Agrega una fila en docs/software/catalogo.md (Software · Versión · Cómo se ofrece · Soporte · Página).
4. Usa estas secciones, en este orden. Puedes agregar secciones propias del programa
   (por ejemplo «GPU (KOKKOS)» en lammps.md) entre «Prueba rápida» y «Cómo citarlo».
5. Datos solo de lo que el sitio ya dice o de estado-actual.md; si falta uno, «por confirmar».
   En español, de tú, para usuarios. Solo Markdown. Nada de datos personales (usa mi-proyecto).
6. En contenedores, empieza en la carpeta actual con --container-workdir="$(pwd -P)", no $PWD.
7. mkdocs build --strict antes de hacer commit.
Borra este comentario en la página nueva.
-->

# <Programa>

## Qué es

<!-- 2–3 líneas: qué hace y para quién sirve. -->

## Versión y cómo se ofrece

<!-- Una línea en negrita: cómo se ofrece (imagen compartida / receta para compilar / del sistema /
     tu entorno de Python) y el nivel de soporte (Mantenido / Probado), con enlace a catalogo.md.
     Luego la versión y, si aplica, la ruta de la imagen o del programa. -->

**<Cómo se ofrece> · Soporte: <Mantenido | Probado>** (ver [Software disponible](catalogo.md)).

## Cómo usarlo

<!-- Un script de sbatch listo para copiar y pegar, y qué cambiar en él. -->

```bash
#!/bin/bash
#SBATCH --job-name=<programa>
#SBATCH --partition=CPU
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=01:00:00
#SBATCH --output=%x_%j.out

<comando>
```

## Prueba rápida

<!-- Un comando corto y lo que debe mostrar. -->

```bash
<comando de prueba>
```

```text
<salida esperada>
```

## Cómo citarlo

<!-- La página oficial de citas del programa, o «por confirmar». -->

## Ayuda

- Documentación oficial: [<sitio>](<url>).
- Dudas: hpc.fisica@usach.cl.
