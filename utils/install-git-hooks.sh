#!/bin/bash
# install-git-hooks.sh — instala los hooks versionados de .githooks/
# en el repo indicado (los hooks NO viajan con git clone/fetch).
#
# Uso:
#   utils/install-git-hooks.sh [--repo PATH] [--remove]
#
# Idempotente. Correr una vez por clon (y tras cada re-clon).
# El cron git-sync.sh commitea vía `git commit`: el hook también corre ahí
# (si aborta, el cron loguea y reintenta la próxima hora; nunca pushea el
# secreto). Emergencias: git commit --no-verify.
set -u

REPO="$PWD"
REMOVE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --repo)   REPO="${2:?falta valor para --repo}"; shift 2 ;;
        --remove) REMOVE=1; shift ;;
        -h|--help) sed -n '1,12p' "$0"; exit 0 ;;
        --*) echo "ERROR: arg desconocido: $1" >&2; exit 1 ;;
        *) REPO="$1"; shift ;;
    esac
done

[ -d "$REPO" ] || { echo "ERROR: repo no encontrado: $REPO" >&2; exit 1; }
TOP="$(git -C "$REPO" rev-parse --show-toplevel 2>/dev/null)" \
    || { echo "ERROR: no es un repo git: $REPO" >&2; exit 1; }

if [ "$REMOVE" -eq 1 ]; then
    git -C "$TOP" config --unset core.hooksPath || true
    echo "hooks desinstalados en $TOP (vuelve a .git/hooks/)"
    exit 0
fi

[ -x "$TOP/.githooks/pre-commit" ] \
    || { echo "ERROR: falta $TOP/.githooks/pre-commit (hacé pull primero)" >&2; exit 1; }
git -C "$TOP" config core.hooksPath .githooks
echo "hooks instalados en $TOP (core.hooksPath=.githooks)"
git -C "$TOP" config --get core.hooksPath
