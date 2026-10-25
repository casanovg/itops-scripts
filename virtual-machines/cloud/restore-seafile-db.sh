#!/bin/sh

# Restore Seafile Docker databases (MariaDB en contenedor seafile-mysql)
# Adaptado de la era binaria (/opt/seafile + mysql host) a Docker 2026-10-25:
#  - sin cliente mysql en el host: se usa `docker exec seafile-mysql mariadb`
#  - password root se lee de /data/seafile-docker/.env (igual que el backup)
#  - se frena nginx + contenedor seafile (app); mysql queda corriendo
#  - la seccion "system files" (/opt/...) ya no aplica: .env/ymls/conf se
#    restauran a mano desde /data/seafile-upgrade/<motivo>-AAAAMMDD-HHMM/
# USO MANUAL E INTERACTIVO (no va en cron). JAMAS imprime passwords.
set -u

PROJ=/data/seafile-docker
DB_CN=seafile-mysql
BACKUP_DATABASE="/data/seafile-data/backup-database"

echo ""
echo " **********************************************"
echo " *     WARNING!     WARNING!     WARNING!     *"
echo " * .......................................... *"
echo " *   If you continue the Seafile file sync    *"
echo " *   service could be severely damaged and    *"
echo " *   become useless. If you are not a system  *"
echo " *   administrator or you do not know what    *"
echo " *   this database restore implies, please    *"
echo " *   exit now!                                *"
echo " **********************************************"
echo ""
printf "Please enter restore to continue, or any key to exit: "
read -r USER_INPUT || exit 1

if [ "$USER_INPUT" = "restore" ] || [ "$USER_INPUT" = "Restore" ] || [ "$USER_INPUT" = "RESTORE" ]; then
    echo ""
    echo "Ok, Seafile databases restore starting ..."
else
    echo ""
    echo "Exiting ..."
    echo ""
    exit 0
fi

[ -f "$PROJ/.env" ] || { echo "ERROR: no existe $PROJ/.env" >&2; exit 1; }
ROOTPW=$(grep ^INIT_SEAFILE_MYSQL_ROOT_PASSWORD "$PROJ/.env" | cut -d= -f2)
[ -n "$ROOTPW" ] || { echo "ERROR: sin root en .env" >&2; exit 1; }

echo ""
echo "Stopping Seafile app + nginx (mysql sigue corriendo) ..."
sudo systemctl stop nginx 2>/dev/null || true
sudo docker stop seafile >/dev/null 2>&1 || true

if [ "$(sudo docker container inspect -f '{{.State.Status}}' "$DB_CN" 2>/dev/null)" != "running" ]; then
    echo ""
    echo "WARNING! $DB_CN no esta corriendo, imposible restaurar."
    sudo systemctl start nginx 2>/dev/null || true
    sudo docker start seafile >/dev/null 2>&1 || true
    unset ROOTPW
    exit 1
fi

# shellcheck disable=SC2012
latest_dump() {
    ls -t "$BACKUP_DATABASE/$1.sql."* 2>/dev/null | head -1
}

FAILED=0
for DB in ccnet_db seafile_db seahub_db; do
    DUMP=$(latest_dump "$DB")
    if [ -z "$DUMP" ]; then
        echo "ERROR: sin dump para $DB en $BACKUP_DATABASE" >&2
        FAILED=1
        continue
    fi
    echo "Restoring $DB desde $(basename "$DUMP") ..."
    if sudo docker exec -i "$DB_CN" mariadb -uroot -p"$ROOTPW" "$DB" < "$DUMP"; then
        echo "  $DB OK"
    else
        echo "  ERROR restaurando $DB" >&2
        FAILED=1
    fi
done
unset ROOTPW

echo ""
echo "Starting Seafile app + nginx ..."
sudo docker start seafile >/dev/null 2>&1 || true
sudo systemctl start nginx 2>/dev/null || true

if [ "$FAILED" -ne 0 ]; then
    echo ""
    echo "RESTORE CON ERRORES: revisar que DBs quedaron a medias."
    exit 1
fi

echo ""
echo "Restore OK. Validar: login web + subida/bajada de archivo."
echo ""
