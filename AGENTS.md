# Notes for AI coding agents

These rules apply to every AI session working in this repo (Claude Code, Codex, any other).

- Read `README.md` and `mkdocs.yml` first. The site is the user guide for the Chuchunco HPC cluster (C3P), built with MkDocs Material and served from the c3p VM at **https://c3p.usach.cl/**. `c3p.fisica.usach.cl` is deprecated; never write it back. The GitHub Pages copy (`c3p-usach.github.io/c3p-docs`) is only a mirror.
- **Content is in Spanish and written for users** (researchers and students), not for admins. Explain what to do, not how the cluster is run internally.
- **`docs/` holds the published site: content pages are Markdown only.** Don't write raw HTML in pages. Styles go in `docs/stylesheets/usach.css`, images in `docs/assets/`. Anything that must not be published (plans, deploy notes, audits) goes in `docs-dev/` or outside the repo.
- **Forms:** every form URL lives once, in `extra.formularios` in `mkdocs.yml`. Pages refer to forms by key (`{{ formulario-enlace: clave }}` for a link, `{{ formulario: clave }}` on its own line for the embedded form; see `hooks/formularios.py`). Never hard-code a form link in a page.
- **No personal data:** no usernames, personal emails, phone numbers, IPs of user machines, or lists of who uses the cluster. Public contact is `hpc.fisica@usach.cl` and the people already named on `contacto.md`.
- **No internal grant administration** (budgets, purchase orders, reports to ANID, evaluation status). The only grant reference allowed is the public acknowledgement text on `agradecimientos.md` (and the footer).
- **Facts about the cluster** (nodes, partitions, limits, quotas, paths, software, network) must come from `Projects/hpc-fisica/11-operacion-admin/estado-actual.md` (outside this repo). If it doesn't state the fact, write «por confirmar» instead of guessing. `grep -rn "por confirmar" docs/` lists what is pending.
- **One hand-off per branch and PR.** Branch from `main`, keep the change to what the hand-off asks, and open a PR. Don't merge it.
- **Victor publishes.** Agents never run anything on the c3p VM or the cluster, never push tags, and never create releases. Publishing steps are in `docs-dev/DEPLOY.md`.
- Verify with `mkdocs build --strict` before committing. CI runs the same build plus an internal link check.
