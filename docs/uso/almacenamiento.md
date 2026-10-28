# Almacenamiento y datos

| Ruta | Para qué | Cuota | Respaldo |
|---|---|---|---|
| `/home/<usuario>` (tu *home*, `~`) | código, scripts, entornos de Python, imágenes `.sqsh`, datos y resultados | sin cuota automática por ahora | **No** |
| `/data/<grupo>` (carpetas de proyecto) | datos compartidos con tu equipo | por confirmar | **No** |

Tu *home* vive en el almacenamiento CEPH del clúster y es **el mismo en todos los nodos**: lo que guardas desde el nodo de entrada lo ve tu trabajo en cualquier nodo de cómputo. En total hay unos **245 TiB utilizables**, compartidos por todos.

Aunque no haya cuota automática, usa solo el espacio que tu proyecto pidió al abrirse ([Solicitar un proyecto](../acceso/solicitar-proyecto.md)).

!!! danger "No hay respaldo"
    CEPH guarda cada dato 3 veces, en servidores distintos, para tolerar fallas de discos. Eso **no es un respaldo**: si borras un archivo, no se puede recuperar. Mantén una copia de lo importante (código en GitHub/GitLab, resultados finales en tu institución).

## Copiar datos

```bash
# Desde tu computador hacia el clúster
rsync -avP mis_datos/ nombre.apellido@158.170.68.170:mis_datos/

# Desde el clúster hacia tu computador
rsync -avP nombre.apellido@158.170.68.170:resultados/ ./resultados/
```

Una ruta sin `/` al inicio (como `mis_datos/`) es relativa a tu *home* en el clúster.

En Windows puedes usar WinSCP o FileZilla (protocolo SFTP, con tu llave SSH).

## Ver cuánto espacio usas

```bash
du -sh ~          # lo que ocupa tu home (puede tardar si tienes muchos archivos)
df -h ~           # espacio libre en total (ver nota)
```

`df` muestra más espacio libre del que de verdad se puede usar: supone que los datos se reparten parejos entre los servidores de almacenamiento, y hoy no es así. La cifra real es la de arriba, unos 245 TiB.

## Buenas prácticas

- No guardes miles de archivos pequeños en una carpeta: empaquétalos (`tar`).
- Borra resultados intermedios que ya no necesites, y las imágenes `.sqsh` que ya no uses.
- Datos personales o sensibles: consúltanos antes de subirlos.
