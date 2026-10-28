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

El sitio canónico es **https://c3p.usach.cl/** (VM c3p, archivos en `/var/www/c3p`). `c3p.fisica.usach.cl` ya no se usa.

- **Por tag (sitio canónico):** al empujar un tag `vYYYY.MM.DD`, GitHub Actions (`release.yml`) construye el sitio y adjunta `site-<tag>.tar.gz` + `.sha256` a un release. En la VM, `sudo publish-c3p-site <tag>` (`deploy/publish-site.sh`) lo descarga, verifica, respalda el sitio vigente e instala. Pasos completos (instalación única, cada release, volver atrás, alternativa sin GitHub) en [`docs-dev/DEPLOY.md`](docs-dev/DEPLOY.md).
- **Espejo — GitHub Pages:** `mirror.yml` publica <https://c3p-usach.github.io/c3p-docs/> en cada push a `main`. Su `<link rel="canonical">` apunta a c3p.usach.cl (por `site_url`), para que los buscadores indexen el sitio canónico.
- **CI:** `ci.yml` corre `mkdocs build --strict` y una revisión de enlaces internos en cada push y PR.

## Formularios

Las URL de los formularios están en un solo lugar: `extra.formularios` en `mkdocs.yml`. Las páginas los nombran por clave (`{{ formulario-enlace: clave }}`, `{{ formulario: clave }}`) y `hooks/formularios.py` pone el enlace o el Google Form incrustado. Ver la tabla en `docs-dev/DEPLOY.md`.

## Pendientes («por confirmar» en el sitio)

`grep -rn "por confirmar" docs/` lista todo lo que falta. Se resuelven con `Projects/hpc-fisica/11-operacion-admin/estado-actual.md`. Quedan (oct 2026): carpetas de proyecto en `/data` y su cuota, contenedores ROCm en las MI210 y la fecha de la próxima inducción.
