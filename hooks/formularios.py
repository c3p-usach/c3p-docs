"""Formularios en un solo lugar.

Las URL viven en `extra.formularios` de mkdocs.yml; las páginas solo nombran la clave:

    {{ formulario-enlace: unirse | proyecto }} en línea: enlace a la primera URL definida
    {{ formulario: unirse | proyecto }}         en su propia línea: Google Form incrustado

`formulario` incrusta solo si la primera URL definida es un Google Form completo
(https://docs.google.com/forms/.../viewform); con un enlace corto (forms.gle) o sin
URL no muestra nada, y el enlace en línea sigue funcionando. Una clave que no está
en mkdocs.yml, o un enlace sin ninguna URL definida, detiene el build.
"""

import html
import re

from mkdocs.exceptions import PluginError

MARCA = re.compile(r"\{\{\s*(formulario|formulario-enlace)\s*:\s*([\w\s|-]+?)\s*\}\}")
GOOGLE_FORM = re.compile(r"^https://docs\.google\.com/forms/.+/viewform")


def _resolver(claves, formularios, pagina):
    for clave in claves:
        if clave not in formularios:
            raise PluginError(f"{pagina}: el formulario '{clave}' no está en extra.formularios (mkdocs.yml)")
    return next((formularios[c] for c in claves if formularios[c]), None)


def _incrustado(url):
    url_tab = html.escape(url)
    src = html.escape(url + ("&" if "?" in url else "?") + "embedded=true")
    return (
        '<div class="c3p-formulario">'
        f'<iframe src="{src}" title="Formulario" loading="lazy">Cargando…</iframe>'
        "</div>\n"
        f'<p class="c3p-formulario-alt"><a href="{url_tab}" target="_blank" rel="noopener">'
        "Abrir el formulario en una pestaña nueva</a></p>"
    )


def on_page_markdown(markdown, page, config, files):
    formularios = config.extra.get("formularios") or {}
    pagina = page.file.src_uri

    def reemplazar(m):
        tipo, claves = m.group(1), [c.strip() for c in m.group(2).split("|")]
        url = _resolver(claves, formularios, pagina)
        if tipo == "formulario-enlace":
            if not url:
                raise PluginError(f"{pagina}: ninguna URL definida para {' | '.join(claves)}")
            return f"<{url}>"
        return _incrustado(url) if url and GOOGLE_FORM.match(url) else ""

    return MARCA.sub(reemplazar, markdown)
