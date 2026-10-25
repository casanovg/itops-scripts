#!/bin/sh
# Backup Seafile Docker (MariaDB en contenedor) - online, sin downtime
# NB-Hibou 2026-10-25. Adaptado de backup-seafile-db.sh (binario).
# Cron: 45 01 * * * (retencion historica: Backintime + OVA semanal)

ENV_FILE="/data/seafile-docker/.env"
BACKUP_DATABASE="/data/seafile-data/backup-database"
BKP_USR="netbackup"
BKP_GRP="wheel"

set +o history
ROOTPW="$(grep -E '^INIT_SEAFILE_MYSQL_ROOT_PASSWORD' "$ENV_FILE" | cut -d= -f2)"
if [ -z "$ROOTPW" ]; then
    echo "ERROR: no se pudo leer root password de $ENV_FILE"
    exit 1
fi

if [ ! -d "$BACKUP_DATABASE" ]; then
    echo "Directory $BACKUP_DATABASE DOES NOT exist, creating it ..."
    mkdir -p "$BACKUP_DATABASE"
fi

for DB in ccnet_db seafile_db seahub_db; do
    echo "Backing $DB up ..."
    rm -f "$BACKUP_DATABASE/${DB}.sql".*
    if sudo docker exec seafile-mysql mysqldump -uroot -p"$ROOTPW" --opt "$DB" > "$BACKUP_DATABASE/${DB}.sql.$(date +"%Y-%m-%d_%H-%M-%S")"; then
        echo "$DB OK"
    else
        echo "ERROR backing $DB up!"
        exit 1
    fi
done
unset ROOTPW
sudo chown -R $BKP_USR:$BKP_GRP "$BACKUP_DATABASE"
echo "Done $(date)"
