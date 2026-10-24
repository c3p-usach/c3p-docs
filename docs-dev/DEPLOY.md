# C3P user guide: how to deploy to c3p.usach.cl

*2026-10-23. Covers the user guide (repo `c3p-usach/c3p-docs`, local copy `Dev/c3p-docs`). This file is outside `docs/`, so it is not published. Same scheme as the HelioUSACH site (`Web/docs/helio-usach-deploy.md`).*

## How it works

**You tag a version on GitHub, then run one command on the c3p VM.** GitHub Actions builds the site (MkDocs) and attaches the finished files (`site-<tag>.tar.gz`, with a `.sha256` checksum) to a GitHub release. `publish-c3p-site <tag>` downloads them, checks them and installs them.

The server never builds anything. Before each install it backs up `/var/www/c3p`, so any version can be rolled back with one command.

| Where | What it is |
|---|---|
| `https://c3p.usach.cl/` | **Canonical site.** Files in `/var/www/c3p` on the c3p VM |
| `https://c3p-usach.github.io/c3p-docs/` | Mirror. Updates automatically on every push to `main` (workflow *Espejo GitHub Pages*). Its `<link rel="canonical">` points to c3p.usach.cl, so search engines index the VM |
| `/var/backups/c3p-site/` (on c3p) | Automatic backups, the newest 15 are kept |
| `https://c3p.usach.cl/build-info.txt` | Shows which tag and commit are live, and when and from where they were installed |

| Workflow | Runs on | Does |
|---|---|---|
| `CI` (`ci.yml`) | every push and PR | `mkdocs build --strict` + internal link check |
| `Espejo GitHub Pages` (`mirror.yml`) | push to `main` | builds and publishes the mirror |
| `Release` (`release.yml`) | tag `v*` | builds and creates the release with `site-<tag>.tar.gz` + `.sha256` |

A change merged into `main` shows up on the mirror within minutes. It reaches c3p.usach.cl only when you publish a new tag.

---

## A. One-time setup

All PC commands are for the WSL terminal on granicus, where the repo is at `~/onedrive/Dev/c3p-docs`.

**A1. Merge the branch.** Open the pull request for `feat/h2-repo-docs`, wait for the **CI** check to pass, and merge it into `main`. The mirror rebuilds by itself after the merge.

**A2. Check the web root on c3p.** The script installs into `/var/www/c3p` and needs `curl` and `rsync`:

```bash
ssh c3p
grep -rn "server_name\|root" /etc/nginx/sites-enabled/   # c3p.usach.cl must have  root /var/www/c3p;
ls -ld /var/www/c3p
command -v curl rsync || sudo apt install -y curl rsync
```

If nginx serves the site from another folder, either change the vhost's `root` to `/var/www/c3p` or run the script with `sudo WEBROOT=/that/folder publish-c3p-site …`.

**A3. Install the publish command on c3p.** This works only **after A1**, because the script is downloaded from `main`. Do it once, and again only if `deploy/publish-site.sh` changes:

```bash
ssh c3p
curl -fsSL https://raw.githubusercontent.com/c3p-usach/c3p-docs/main/deploy/publish-site.sh -o /tmp/publish-site.sh
sudo install -m 755 /tmp/publish-site.sh /usr/local/sbin/publish-c3p-site
publish-c3p-site --help
```

A `404` from curl means the branch isn't merged yet.

---

## B. Every release (about 3 minutes)

**B1. On your PC** (WSL):

```bash
cd ~/onedrive/Dev/c3p-docs
git switch main
git pull
git tag v2026.10.23          # today's date; for a second release the same day use v2026.10.23.2
git push origin v2026.10.23
```

**B2.** On GitHub, open **Actions → Release** and wait for the green check (about 1 min). A release named *Site v2026.10.23* should then appear under **Releases**.

**B3. On c3p:**

```bash
ssh c3p
sudo publish-c3p-site v2026.10.23
```

The command downloads the build, checks its checksum, backs up `/var/www/c3p`, installs the new files, writes `build-info.txt` and confirms that `/` responds. It then prints the contents of `build-info.txt`.

**B4. Check it in a browser:** open `https://c3p.usach.cl/` and press Ctrl+F5. Open the page you changed and confirm the change is there.

## C. Rolling back

```bash
sudo publish-c3p-site v2026.10.01                 # reinstall an earlier tag, or:
sudo publish-c3p-site --restore                   # list backups (newest first)
sudo publish-c3p-site --restore /var/backups/c3p-site/c3p-20261023-153000.tar.gz
```

The first time you publish, the backup it takes is the site that is live right now (the one copied by `rsync` under the old README instructions).

## D. Fallback without GitHub (GitHub down, or a quick test)

On your PC (WSL, in `~/onedrive/Dev/c3p-docs`):

```bash
pip install -r requirements.txt
mkdocs build --strict
ssh c3p "rm -rf /tmp/c3p-site"
scp -r site c3p:/tmp/c3p-site
```

On c3p:

```bash
sudo publish-c3p-site --from /tmp/c3p-site
rm -rf /tmp/c3p-site
```

This path uses whatever is in your working copy, uncommitted changes included, and `build-info.txt` says "local build". Use the tag route for normal releases.

---

## Forms

Form URLs live only in `extra.formularios` in `mkdocs.yml`. To switch a page to an embedded form, paste the Google Form's full URL (`https://docs.google.com/forms/d/e/<id>/viewform`, from **Send → link**, not the short `forms.gle` one) into its key, open a PR, merge, and publish a tag. Until a key has that kind of URL, the page shows the plain link as it does today.

| Key | Form | Used on |
|---|---|---|
| `productos` | F4 · product registry | `agradecimientos.md` |
| `proyecto` | F1 · project request (PI) | `acceso/solicitar-proyecto.md` |
| `unirse` | F2 · join a project | `acceso/unirse.md` |
| `soporte` | F3 · support | `contacto.md` (embedded only; nothing shows while empty) |

## Not verified from here

- **Downloads from c3p:** I didn't run anything on the VM. Plan §7 shows outbound HTTPS from c3p works (to Google), but release files are served from `objects.githubusercontent.com`. If B3 fails at "Downloading", use section D and tell me.
- **nginx root:** I assumed `/var/www/c3p`, as in the old README. A2 checks it.
- The script was tested locally against a fake web root (tag install from a `file://` release, `--from`, `--restore`, bad checksum, missing tag), not on c3p.
