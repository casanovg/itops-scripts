#!/bin/sh
# rotate-seafile-db-passwords.sh — Rota los passwords de MariaDB de Seafile.
#
# IMPORTANTE: Seafile usa MariaDB/MySQL (contenedor seafile-mysql).
# NO hay Postgres en este despliegue.
#
# Alcance: password del usuario de la app (SEAFILE_MYSQL_DB_PASSWORD) y
# password de root de MariaDB (INIT_SEAFILE_MYSQL_ROOT_PASSWORD). Ambos
# aparecieron en texto plano en un transcript de sesion (2026-10) y por
# eso se rotan. El JWT de OnlyOffice, el admin y el token de Cloudflare
# NO se expusieron y NO se tocan con este script.
#
# Uso:
#   rotate-seafile-db-passwords.sh [--app-only | --root-only] [--yes]
#   rotate-seafile-db-passwords.sh --rollback <dir-rot-AAAAMMDD-HHMM>
#
# Requiere sudo (docker) y openssl. Ventana sugerida fuera de 01:30-04:30
# (backup cron 01:55 + pull Backintime ~04:00). JAMAS imprime passwords.
set -eu

PROJ=/data/seafile-docker
BKBASE=/data/seafile-upgrade
DB_CN=seafile-mysql
APP_KEY=SEAFILE_MYSQL_DB_PASSWORD
ROOT_KEY=INIT_SEAFILE_MYSQL_ROOT_PASSWORD
APP_DB_USER=seafile

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "== $*"; }

MODE=both
YES=0
ROLLBACK_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --app-only) MODE=app ;;
    --root-only) MODE=root ;;
    --yes) YES=1 ;;
    --rollback) ROLLBACK_DIR="${2:?falta directorio de backup}"; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) die "opcion desconocida: $1 (usar --help)" ;;
  esac
  shift
done

[ -f "$PROJ/.env" ] || die "no existe $PROJ/.env"
grep -q "^$APP_KEY=" "$PROJ/.env" || die "falta $APP_KEY en .env"
grep -q "^$ROOT_KEY=" "$PROJ/.env" || die "falta $ROOT_KEY en .env"
command -v openssl >/dev/null || die "falta openssl"
sudo docker container inspect "$DB_CN" >/dev/null 2>&1 \
  || die "contenedor $DB_CN no accesible (revisar sudo/docker)"

db_exec_root() {
  # $1 = password root para autenticar; resto = args de mariadb
  _pw="$1"; shift
  sudo docker exec -i "$DB_CN" mariadb -uroot -p"$_pw" "$@"
}

alter_users() {
  # $1 = root pw actual (auth); $2 = nuevo root ("" = no tocar);
  # $3 = nuevo app ("" = no tocar). La app primero: el auth no cambia
  # hasta rotar root, asi el mismo $1 sirve para todo.
  if [ -n "$3" ]; then
    for h in $(db_exec_root "$1" -N -e "SELECT host FROM mysql.user WHERE user='$APP_DB_USER';"); do
      db_exec_root "$1" -e "ALTER USER '$APP_DB_USER'@'$h' IDENTIFIED BY '$3';" \
        || die "fallo ALTER $APP_DB_USER@$h"
    done
  fi
  if [ -n "$2" ]; then
    for h in $(db_exec_root "$1" -N -e "SELECT host FROM mysql.user WHERE user='root';"); do
      db_exec_root "$1" -e "ALTER USER 'root'@'$h' IDENTIFIED BY '$2';" \
        || die "fallo ALTER root@$h"
    done
  fi
  db_exec_root "$1" -e "FLUSH PRIVILEGES;"
}

verify_logins() {
  # $1 = root pw a probar; $2 = app pw a probar ("" = saltear)
  db_exec_root "$1" -e "SELECT 1;" >/dev/null \
    || die "login root nuevo NO funciona"
  if [ -n "$2" ]; then
    sudo docker exec -i "$DB_CN" mariadb -u"$APP_DB_USER" -p"$2" \
      -e "SELECT 1;" >/dev/null || die "login $APP_DB_USER nuevo NO funciona"
  fi
}

wait_login_200() {
  i=0; code=""
  while [ $i -lt 30 ]; do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 \
      http://127.0.0.1:8085/accounts/login/ 2>/dev/null || true)
    [ "$code" = "200" ] && break
    sleep 10; i=$((i + 1))
  done
  [ "$code" = "200" ] || die "login interno no da 200 (code=$code)"
  info "login interno 200 OK"
}

# Precheck (solo rotacion, no rollback): el root actual del .env debe
# autenticar. Si .env y DB estan desincronizados, abortar SIN TOCAR NADA
# (ver CHEAT-SHEET: recuperacion por desincronizacion).
if [ -z "$ROLLBACK_DIR" ]; then
  _PRE_ROOT=$(grep "^$ROOT_KEY=" "$PROJ/.env" | cut -d= -f2)
  db_exec_root "$_PRE_ROOT" -N -e "SELECT 1;" >/dev/null \
    || die "el root de .env NO autentica en MariaDB (.env y DB desincronizados). Abortado sin cambios."
  unset _PRE_ROOT
fi

if [ -n "$ROLLBACK_DIR" ]; then
  info "ROLLBACK desde $ROLLBACK_DIR"
  [ -d "$ROLLBACK_DIR" ] || die "no existe $ROLLBACK_DIR"
  [ -f "$ROLLBACK_DIR/.env" ] || die "sin .env en el backup"
  [ -f "$ROLLBACK_DIR/passwords.env" ] || die "sin passwords.env en el backup"
  # shellcheck disable=SC1091
  . "$ROLLBACK_DIR/passwords.env" # define MODE OLD_APP OLD_ROOT NEW_APP NEW_ROOT
  cp -a "$PROJ/.env" "$PROJ/.env.pre-rollback-$(date +%Y%m%d-%H%M)"
  cp -a "$ROLLBACK_DIR/.env" "$PROJ/.env"
  chmod 600 "$PROJ/.env"
  R_NR=""; R_NA=""
  [ "$MODE" != "app" ] && R_NR="$OLD_ROOT"
  [ "$MODE" != "root" ] && R_NA="$OLD_APP"
  alter_users "$NEW_ROOT" "$R_NR" "$R_NA"
  cd "$PROJ" && sudo docker compose up -d
  wait_login_200
  unset OLD_APP OLD_ROOT NEW_APP NEW_ROOT R_NR R_NA
  info "rollback OK; validar login web + subida/bajada de archivo"
  exit 0
fi

H=$(date +%H)
if [ "$H" -ge 1 ] && [ "$H" -lt 5 ]; then
  echo "AVISO: ventana de backup 01:30-04:30, preferible rotar fuera de ella."
fi

if [ "$YES" -eq 0 ]; then
  printf 'Rotar passwords MariaDB Seafile (modo=%s). Continuar? (s/N): ' "$MODE"
  read -r ans </dev/tty || ans=""
  [ "$ans" = "s" ] || die "cancelado por el operador"
fi

umask 077
TS=$(date +%Y%m%d-%H%M)
BK="$BKBASE/rot-$TS"
mkdir -p -m 700 "$BK"
cp -a "$PROJ/.env" "$PROJ"/seafile-server.yml "$PROJ"/seadoc.yml \
  "$PROJ"/onlyoffice.yml "$PROJ"/notification-server.yml \
  "$PROJ"/md-server.yml "$PROJ"/seafile-ai.yml "$BK/" 2>/dev/null || true
cp -a /data/seafile-docker-data/seafile/conf/seafile.conf \
  /data/seafile-docker-data/seafile/conf/seahub_settings.py "$BK/"
info "backup en $BK"

OLD_APP=$(grep "^$APP_KEY=" "$PROJ/.env" | cut -d= -f2)
OLD_ROOT=$(grep "^$ROOT_KEY=" "$PROJ/.env" | cut -d= -f2)
NEW_APP=""; NEW_ROOT=""
[ "$MODE" != "root" ] && NEW_APP=$(openssl rand -hex 24)
[ "$MODE" != "app" ] && NEW_ROOT=$(openssl rand -hex 24)
cat > "$BK/passwords.env" <<EOF
MODE=$MODE
OLD_APP=$OLD_APP
OLD_ROOT=$OLD_ROOT
NEW_APP=$NEW_APP
NEW_ROOT=$NEW_ROOT
EOF
chmod 600 "$BK/passwords.env"

alter_users "$OLD_ROOT" "$NEW_ROOT" "$NEW_APP"
info "ALTER USER OK"
verify_logins "${NEW_ROOT:-$OLD_ROOT}" "$NEW_APP"

[ -n "$NEW_APP" ] && sed -i -E "s/^($APP_KEY)=.*/\1=$NEW_APP/" "$PROJ/.env"
[ -n "$NEW_ROOT" ] && sed -i -E "s/^($ROOT_KEY)=.*/\1=$NEWROOT/" "$PROJ/.env"
chmod 600 "$PROJ/.env"
info ".env actualizado"

cd "$PROJ" && sudo docker compose up -d
info "contenedores recreados (up -d recarga .env; restart NO lo hace)"
wait_login_200

unset OLD_APP OLD_ROOT NEW_APP NEW_ROOT
info "OK modo=$MODE backup=$BK"
info "Siguiente: login web + subida/bajada de archivo, y backup manual"
info "  ($HOME/itops-scripts/virtual-machines/cloud/backup-seafile-docker-db.sh)"
info "Rollback si algo falla: $0 --rollback $BK"
