#!/usr/bin/env bash
# Publishes the C3P user guide on the c3p VM (https://c3p.usach.cl/).
#
# The site is built by GitHub Actions, never on the server: pushing a tag
# vYYYY.MM.DD makes CI attach site-<tag>.tar.gz (the built site/) and its
# .sha256 to a GitHub release. This script downloads that file, checks it,
# backs up the live folder, swaps the new files in and writes build-info.txt.
# Adapted from the HelioUSACH site's publish-helio-site.
#
# Usage (on c3p):
#   sudo publish-c3p-site v2026.10.23              # publish a tagged release
#   sudo publish-c3p-site --from /tmp/c3p-site     # publish a site/ copied by hand
#   sudo publish-c3p-site --restore                # list backups
#   sudo publish-c3p-site --restore <backup.tar.gz>
#
# Only the static root is touched. nginx and certbot's /.well-known/ are left alone.
set -euo pipefail

REPO="c3p-usach/c3p-docs"
WEBROOT="${WEBROOT:-/var/www/c3p}"
BACKUPS="${BACKUPS:-/var/backups/c3p-site}"
KEEP=15
PUBLIC_URL="${PUBLIC_URL:-https://c3p.usach.cl}"

die() { echo "ERROR: $*" >&2; exit 1; }
case "${1:-}" in "" | -h | --help) sed -n '2,17p' "$0"; exit 0 ;; esac
[[ $EUID -eq 0 ]] || die "run with sudo"
[[ -d $WEBROOT ]] || die "$WEBROOT does not exist"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

backup() {
    install -d -m 750 "$BACKUPS"
    local f="$BACKUPS/c3p-$(date +%Y%m%d-%H%M%S).tar.gz"
    tar -czf "$f" -C "$WEBROOT" .
    echo "==> Backup of the current site: $f"
    # keep the newest $KEEP backups
    ls -1t "$BACKUPS"/c3p-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)) | xargs -r rm -f
}

install_tree() {  # $1 = folder holding the new site; $2 = what it is (for build-info.txt); $3 = "nocheck" for backups
    local src="$1" what="$2"
    [[ ${3:-} == nocheck || ( -f $src/index.html && -f $src/acceso/solicitar-cuenta.html ) ]] \
        || die "$src does not look like the built site (index.html, acceso/solicitar-cuenta.html missing)"
    local owner; owner="$(stat -c %U:%G "$WEBROOT")"
    # first line of the CI stamp (tag, commit, build time); a local build has none
    local stamp="local build"
    [[ -f $src/build-info.txt ]] && stamp="$(head -1 "$src/build-info.txt")"
    backup
    echo "==> Installing into $WEBROOT (owner $owner)"
    rsync -rlt --delete --chown="$owner" --chmod=D755,F644 \
        --exclude='/.well-known/' \
        "$src/" "$WEBROOT/"
    printf '%s\ninstalled %s on %s from %s\n' "$stamp" "$(date -u +%Y-%m-%dT%H:%MZ)" "$(hostname -s)" "$what" \
        > "$WEBROOT/build-info.txt"
    chown "$owner" "$WEBROOT/build-info.txt"; chmod 644 "$WEBROOT/build-info.txt"
}

check() {
    echo "==> Checking $PUBLIC_URL/"
    curl -fsS -o /dev/null "$PUBLIC_URL/" \
        || die "site does not answer: restore with  sudo publish-c3p-site --restore"
    curl -fsS "$PUBLIC_URL/build-info.txt" 2>/dev/null || true
    echo "Done."
}

case "${1:-}" in
    --from)
        SRC="${2:?--from needs a folder (a copy of site/)}"
        [[ -d $SRC ]] || die "$SRC is not a folder"
        install_tree "$SRC" "$SRC"
        check ;;
    --restore)
        if [[ -z ${2:-} ]]; then
            echo "Backups (newest first):"; ls -1t "$BACKUPS"/c3p-*.tar.gz 2>/dev/null || echo "  (none)"
            echo "Restore one with:  sudo publish-c3p-site --restore <file>"; exit 0
        fi
        [[ -f $2 ]] || die "$2 not found"
        mkdir "$WORK/site"; tar -xzf "$2" -C "$WORK/site"
        install_tree "$WORK/site" "backup $(basename "$2")" nocheck
        check ;;
    v*)
        TAG="$1"
        BASE="${RELEASES:-https://github.com/$REPO/releases/download}/$TAG"
        echo "==> Downloading $TAG"
        curl -fsSL -o "$WORK/site-$TAG.tar.gz" "$BASE/site-$TAG.tar.gz" \
            || die "no build for $TAG on GitHub (did the 'Release' workflow finish for that tag?)"
        curl -fsSL -o "$WORK/site-$TAG.tar.gz.sha256" "$BASE/site-$TAG.tar.gz.sha256" \
            || die "no checksum file for $TAG"
        (cd "$WORK" && sha256sum -c --quiet "site-$TAG.tar.gz.sha256") || die "checksum mismatch"
        mkdir "$WORK/site"; tar -xzf "$WORK/site-$TAG.tar.gz" -C "$WORK/site"
        install_tree "$WORK/site" "release $TAG"
        check ;;
    *)
        die "unknown argument '$1' (use a tag like v2026.10.23, --from <dir> or --restore)" ;;
esac
