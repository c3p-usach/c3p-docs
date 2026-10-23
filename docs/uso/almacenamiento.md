# Almacenamiento y datos

| Ruta | Para qué | Cuota | Respaldo |
|---|---|---|---|
| `/home/<usuario>` | código, scripts, configuración | por confirmar | **No** |
| `/data` (CEPH) | datos de entrada, resultados, imágenes `.sqsh` | por confirmar | **No** |

!!! danger "No hay respaldo"
    CEPH replica los datos entre discos para tolerar fallas de hardware, pero **no es un respaldo**: si borras un archivo, no se puede recuperar. Mantén una copia de lo importante (código en GitHub/GitLab, resultados finales en tu institución).

## Copiar datos

```bash
# Desde tu computador hacia el clúster
rsync -avP mis_datos/ nombre.apellido@158.170.68.170:/data/<grupo>/mis_datos/

# Desde el clúster hacia tu computador
rsync -avP nombre.apellido@158.170.68.170:/data/<grupo>/resultados/ ./resultados/
```

En Windows puedes usar WinSCP o FileZilla (protocolo SFTP, con tu llave SSH).

## Ver cuánto espacio usas

```bash
du -sh ~ /data/<grupo>
df -h /data
```

## Buenas prácticas

- No guardes miles de archivos pequeños en una carpeta: empaquétalos (`tar`).
- Borra resultados intermedios que ya no necesites.
- Datos personales o sensibles: consúltanos antes de subirlos.
