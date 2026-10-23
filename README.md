# Sitio de usuarios — C3P / Chuchunco

Sitio estático hecho con [MkDocs Material](https://squidfunk.github.io/mkdocs-material/). El contenido está en `docs/` (Markdown); la navegación en `mkdocs.yml`.

## Trabajar en local

```bash
pip install -r requirements.txt
mkdocs serve          # vista previa en http://127.0.0.1:8000, se recarga al guardar
mkdocs build          # genera el sitio en site/
```

También se puede abrir `site/index.html` directamente (doble clic): el plugin `offline` y `use_directory_urls: false` hacen que la navegación y el modo día/noche funcionen sin servidor. La búsqueda puede no aparecer al abrir archivos locales; en el servidor y con `mkdocs serve` funciona.

## Identidad visual

`docs/stylesheets/usach.css` aplica el Manual de Normas Gráficas USACH 2024: gris pizarra #394049 (encabezado), teal #00A499 y naranjo #E77500 (acentos), Bebas Neue para títulos y Nunito Sans para texto. Los enlaces usan un teal más oscuro (#00756D) para cumplir contraste WCAG AA. Sin logos institucionales; el ícono `assets/logo-c3p.svg` es provisorio.

## Publicar

**Interino — GitHub Pages:** subir este directorio a un repo de GitHub (p. ej. `c3p-usach/docs`). El workflow `.github/workflows/deploy.yml` construye y publica en cada push a `main` (activar Pages → Source: GitHub Actions en la configuración del repo).

**Definitivo — c3p.fisica.usach.cl (VM 158.170.68.239):** requiere que SEGIC abra 80/443 o configure un túnel Cloudflare. Luego:

```bash
# una vez, en la VM
sudo apt install -y nginx certbot python3-certbot-nginx
sudo mkdir -p /var/www/c3p && sudo chown $USER /var/www/c3p
# configurar server_name c3p.fisica.usach.cl con root /var/www/c3p

# cada actualización, desde tu computador
mkdocs build && rsync -avz --delete site/ c3p-fisica:/var/www/c3p/
```

## Pendientes («por confirmar» en el sitio)

`grep -rn "por confirmar" docs/` lista todo lo que falta. La mayoría se resuelve con el levantamiento as-built del head node (`../11-operacion-admin/`) y la respuesta de XI: límites de tiempo, cuotas, rutas de `/data`, `seff`/correo, Jupyter, cantidad de MI210.
