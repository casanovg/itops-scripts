#!/bin/sh
# Backup Seafile Docker databases (MariaDB en contenedor seafile-mysql)
# Politica: solo ULTIMA copia en host (igual que antes); retencion la da
# Backintime en 10.77.77.40 que levanta /data/seafile-data/backup-database/
set -u
BACKUP_DATABASE="/data/seafile-data/backup-database"
mkdir -p "$BACKUP_DATABASE"
cd /data/seafile-docker || exit 1
ROOTPW=$(grep ^INIT_SEAFILE_MYSQL_ROOT_PASSWORD .env | cut -d= -f2)
STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
for DB in ccnet_db seafile_db seahub_db; do
    echo "Dumping $DB ..."
    rm -f "$BACKUP_DATABASE/$DB.sql."*
    sudo docker exec seafile-mysql mariadb-dump -uroot -p"$ROOTPW" --single-transaction --opt "$DB" > "$BACKUP_DATABASE/$DB.sql.$STAMP" || exit 1
done
echo "OK $STAMP"
