# Almacenamiento y datos

**Tus datos van en la carpeta del proyecto, no en tu carpeta personal.**

| Lugar | Ruta | Para qué | Límite | Respaldo |
|---|---|---|---|---|
| Carpeta del proyecto | `/data/proyectos/<proyecto>` | los datos del proyecto y los resultados grandes, compartidos con tu equipo | **5 TB por proyecto**, para todo el equipo | **No** |
| Carpeta personal (*home*) | `/home/<usuario>` (`~`) | código, scripts, entornos de Python, imágenes `.sqsh` y resultados pequeños | **1 TB** por persona | **No** |

`<proyecto>` es el nombre corto de tu proyecto, el mismo de tu cuenta en Slurm: lo que muestra `sacctmgr show assoc user=$USER format=account%30` (por ejemplo, `mi-proyecto`). Si estás en varios proyectos, tienes una carpeta por cada uno.

Las dos carpetas viven en el almacenamiento CEPH del clúster y son **las mismas en todos los nodos**: lo que guardas desde el nodo de entrada lo ve tu trabajo en cualquier nodo de cómputo. En total hay unos **245 TiB utilizables**, compartidos por todos.

!!! danger "No hay respaldo"
    CEPH guarda cada dato 3 veces, en servidores distintos, para tolerar fallas de discos. Eso **no es un respaldo**: si borras un archivo, no se puede recuperar. Mantén una copia de lo importante (código en GitHub/GitLab, resultados finales en tu institución).

## La carpeta del proyecto

- Solo los miembros del proyecto pueden entrar en ella.
- Los archivos que creas ahí pertenecen al grupo del proyecto y el grupo puede escribir en ellos: tu equipo puede leer y editar los archivos de los demás.
- Si te acaban de agregar a un proyecto, tendrás acceso a su carpeta la próxima vez que te conectes.

```bash
ls /data/proyectos                  # busca la carpeta de tu proyecto
cd /data/proyectos/mi-proyecto
mkdir -p datos resultados
```

## Copiar datos

```bash
# Desde tu computador hacia la carpeta del proyecto
rsync -avP mis_datos/ nombre.apellido@158.170.68.170:/data/proyectos/mi-proyecto/datos/

# Desde el clúster hacia tu computador
rsync -avP nombre.apellido@158.170.68.170:/data/proyectos/mi-proyecto/resultados/ ./resultados/
```

Una ruta sin `/` al inicio (como `mis_datos/`) es relativa a tu *home* en el clúster; para la carpeta del proyecto, escribe la ruta completa.

En Windows puedes usar WinSCP o FileZilla (protocolo SFTP, con tu llave SSH).

## Ver cuánto espacio usas

El espacio usado y el límite se leen con `getfattr`:

```bash
getfattr -n ceph.dir.rbytes     /data/proyectos/mi-proyecto   # bytes usados
getfattr -n ceph.quota.max_bytes /data/proyectos/mi-proyecto  # límite, en bytes
```

Para tu *home*, lo mismo con `~` en vez de la ruta del proyecto.

Las cifras salen en bytes. Para verlas en GB o TB, usa `numfmt`:

```bash
numfmt --to=iec $(getfattr --only-values -n ceph.dir.rbytes /data/proyectos/mi-proyecto)
numfmt --to=iec $(getfattr --only-values -n ceph.quota.max_bytes /data/proyectos/mi-proyecto)
numfmt --to=iec $(getfattr --only-values -n ceph.dir.rbytes ~)
```

Muestran algo como `730G` o `4.5T`.

`df -h` no sirve para esto: muestra el espacio de todo el clúster, y además más espacio libre del que de verdad se puede usar.

## Si llegas al límite

Cuando una carpeta llega a su límite, todo lo que intente escribir en ella falla con:

```text
Disk quota exceeded
```

Pasa también dentro de tus trabajos: un programa que no puede guardar sus resultados termina con error. En la carpeta del proyecto el límite es de todo el equipo, así que también les afecta a los demás.

Qué hacer:

1. Mira cuánto usas (arriba) y borra lo que ya no necesites.
2. Si el proyecto de verdad necesita más de 5 TB, pídelo a hpc.fisica@usach.cl, explicando para qué.

## Buenas prácticas

- No guardes miles de archivos pequeños en una carpeta: empaquétalos (`tar`).
- Borra resultados intermedios que ya no necesites, y las imágenes `.sqsh` que ya no uses.
- Datos personales o sensibles: consúltanos antes de subirlos.
