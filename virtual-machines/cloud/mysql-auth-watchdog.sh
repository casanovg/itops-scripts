#!/bin/sh
# Watchdog: verifica que el .env matchee la DB (MariaDB Docker).
# No imprime ni guarda valores, solo OK/FAIL con hora. Sirve para
# detectar una desincronizacion .env<->DB y acotar CUANDO ocurrio.
# Cron sugerido: */5 * * * * (usuario netbackup, sudo sin password).
set -u
PROJ=/data/seafile-docker
LOG=$HOME/itops-scripts/virtual-machines/cloud/mysql-auth-watch.log
TS=$(date '+%F %H:%M')
R=$(grep ^INIT_SEAFILE_MYSQL_ROOT_PASSWORD "$PROJ/.env" | cut -d= -f2)
A=$(grep ^SEAFILE_MYSQL_DB_PASSWORD "$PROJ/.env" | cut -d= -f2)
if sudo -n docker exec -i seafile-mysql mariadb -uroot -p"$R" -N -e "SELECT 1;" >/dev/null 2>&1; then ROK=OK; else ROK=FAIL; fi
if sudo -n docker exec -i seafile-mysql mariadb -useafile -p"$A" -N -e "SELECT 1;" >/dev/null 2>&1; then AOK=OK; else AOK=FAIL; fi
unset R A
echo "$TS root=$ROK app=$AOK" >> "$LOG"
