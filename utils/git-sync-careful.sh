#!/bin/bash
# git-sync-careful.sh — sincronizacion git cuidadosa para sesiones humanas.
#
# A diferencia de utils/git-sync.sh (cron horario: stagea todo, mensaje fijo,
# `git pull` plano), este script:
#   - nunca stagea archivos que no nombraste (sin --only/--all aborta),
#   - corre higiene de secretos antes de commitear,
#   - trae con --rebase (sin merge commits) y frena en conflictos,
#   - lleva (--push) solo si se lo pedis.
#
# Uso:
#   git-sync-careful.sh [--check] [repo-path]
#       Solo informe: rama, estado, behind/ahead vs origin. Modo default.
#   git-sync-careful.sh -m "mensaje" [--only f1 f2 ... | --all] [--push] [repo-path]
#       Commitea (solo --only, o todo con --all), rebase contra origin,
#       pushea si se paso --push.
#
# Salidas: 0 ok / en sync; 1 error; 2 accion requerida (arbol sucio,
# conflicto, o falta --push).

set -u
MODE=check
MSG=""
PUSH=0
STAGE_ALL=0
ONLY=()
REPO=""

while [ $# -gt 0 ]; do
  case "$1" in
    -m|--message) MSG="$2"; MODE=commit; shift 2;;
    --only) MODE=commit; shift; while [ $# -gt 0 ] && [[ "$1" != -* ]]; do ONLY+=("$1"); shift; done;;
    --all) STAGE_ALL=1; MODE=commit; shift;;
    --push) PUSH=1; shift;;
    --check) MODE=check; shift;;
    -h|--help) sed -n '1,20p' "$0"; exit 0;;
    *) if [ -z "$REPO" ]; then REPO="$1"; shift; else echo "ERROR: arg desconocido: $1" >&2; exit 1; fi;;
  esac
done

[ -n "$REPO" ] && cd "$REPO" || true
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: no estas dentro de un repo git (ruta: ${REPO:-.})" >&2; exit 1
fi
TOP="$(git rev-parse --show-toplevel)"
BR="$(git rev-parse --abbrev-ref HEAD)"
cd "$TOP" || exit 1

git fetch origin 2>&1 | grep -v '^ *$' || true
BEHIND=$(git rev-list --count HEAD..'@{u}' 2>/dev/null || echo "?")
AHEAD=$(git rev-list --count '@{u}'..HEAD 2>/dev/null || echo "?")
echo "### $(basename "$TOP") [$BR] behind=$BEHIND ahead=$AHEAD"
git status -sb | head -10

if [ "$MODE" = check ]; then
  git diff --stat | tail -2
  if [ "$BEHIND" != 0 ] && [ "$BEHIND" != "?" ]; then echo "HAY QUE TRAER: $BEHIND commits de origin/$BR."; fi
  if [ "$AHEAD" != 0 ] && [ "$AHEAD" != "?" ]; then echo "HAY QUE LLEVAR: $AHEAD commits locales (re-corre con -m/--push)."; fi
  exit 0
fi

# --- commit ---
if [ -z "$MSG" ]; then echo "ERROR: -m es obligatorio para commitear" >&2; exit 1; fi
if [ "${#ONLY[@]}" -eq 0 ] && [ "$STAGE_ALL" -eq 0 ]; then
  if git diff --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "Arbol limpio: nada que commitear, sigo a pull/push."
  else
    echo "ERROR: arbol sucio y no pasaste --only <archivos> ni --all." >&2
    echo "Para no pisar trabajo ajeno hay que nombrar archivos. Ej.:" >&2
    echo "  $0 -m \"docs: ...\" --only AGENTS.md docs/x.md [repo]" >&2
    exit 2
  fi
else
  if [ "$STAGE_ALL" -eq 1 ]; then git add -A; else git add -- "${ONLY[@]}"; fi
  echo "--- higiene de secretos sobre el diff staged (lineas agregadas) ---"
  ADDED="$(git diff --cached -U0 | grep '^+' | grep -v '^+++')"
  if echo "$ADDED" | grep -nEi '(password|token|secret|api[_-]?key)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9/+_.-]{6,}'; then
    echo "ABORTO: posible secreto en el diff (ver arriba)." >&2; exit 1
  fi
  # Nota: los patrones evitan auto-matchearse ([Y],[A],[p]) para no abortar
  # cuando el diff agrega estas mismas lineas del script.
  if echo "$ADDED" | grep -nE 'BEGIN [A-Z ]*PRIVATE KE[Y]|ssh-(rsa|ed25519) AAA[A]|gh[p]_|AKI[A][0-9A-Z]{16}'; then
    echo "ABORTO: posible clave/token en el diff (ver arriba)." >&2; exit 1
  fi
  echo "higiene OK"
  git commit -m "$MSG" || { echo "ERROR: commit fallo" >&2; exit 1; }
fi

# --- pull (recomputa behind por si el commit movio HEAD) ---
BEHIND=$(git rev-list --count HEAD..'@{u}' 2>/dev/null || echo "?")
if [ "$BEHIND" != 0 ] && [ "$BEHIND" != "?" ]; then
  echo "--- pull --rebase --autostash origin/$BR ---"
  if ! GIT_EDITOR=true git pull --rebase --autostash origin "$BR"; then
    echo "CONFLICTO: rebase frenado con marcas de conflicto. Resolvelo a mano," >&2
    echo "  GIT_EDITOR=true git rebase --continue, y despues pushea." >&2
    exit 2
  fi
fi

# --- push ---
AHEAD=$(git rev-list --count '@{u}'..HEAD 2>/dev/null || echo "?")
if [ "$AHEAD" != 0 ] && [ "$AHEAD" != "?" ]; then
  if [ "$PUSH" -eq 1 ]; then
    git push origin "$BR" || { echo "ERROR: push fallo" >&2; exit 1; }
  else
    echo "LOCAL $AHEAD commits adelante. Re-corre con --push para llevarlos."
    exit 2
  fi
fi

echo "--- SYNC OK ---"; git status -sb | head -3; git log --oneline -2
exit 0
