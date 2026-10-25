#!/bin/bash
# Seafile storage maintenance (Docker version)
# Adaptado de itops-scripts/.../seafile-storage-cleanup.sh (binario) a contenedor.
# Parar/arrancar = servicios internos del container (el container sigue up).
# NOTA: fsck+GC en 176GB/3M archivos tarda horas, con servicio caido. Ventana: sab 07:00.
# Cron: 0 7 * * sat (usuario netbackup). Solo guarda el ULTIMO log en maintenance-log/.
set -u

LATEST=/opt/seafile/seafile-server-latest
LOG_PATH="/data/seafile-docker/maintenance-log"
LOG_FILE="Seafile-Maintenance-$(date +%Y-%m-%d).log"
mkdir -p $LOG_PATH
rm -rf $LOG_PATH/* 1>/dev/null 2>/dev/null

RC_FSCK=0; RC_GC=0; RC_SESS=0; RC_REPO=0

log() { echo "$@" 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE; }
log ""; log "Seafile Maintenance Routine (Docker)"; log "==========================="; log ""
log "START:" $(date "+%F %H:%M:%S"); log ""
log "Imagenes:"; sudo docker ps --format "{{.Names}} {{.Image}}" 2>/dev/null | grep -E "seafile|redis" 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE; log ""

log "Stopping internal services ..."
sudo docker exec seafile $LATEST/seahub.sh stop 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo docker exec seafile $LATEST/seafile.sh stop 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
log ""
log "Giving the server some time to shut down properly ..."
sleep 20

log "Check and repair libraries ..."
sudo docker exec seafile $LATEST/seaf-fsck.sh --repair 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE || RC_FSCK=$?
log "seaf-fsck rc=$RC_FSCK"
log ""
sleep 10

log "Seafile cleanup started ..."
sudo docker exec seafile $LATEST/seaf-gc.sh 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE || RC_GC=$?
log "seaf-gc rc=$RC_GC"
log ""
sleep 10

log "Clear expired session records ..."
sudo docker exec seafile $LATEST/seahub.sh python-env $LATEST/seahub/manage.py clearsessions 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE || RC_SESS=$?
log "clearsessions rc=$RC_SESS"
sleep 10

log "Starting internal services ..."
sudo docker exec seafile $LATEST/seafile.sh start 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo docker exec seafile $LATEST/seahub.sh start 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
log ""

log "Clear outdated library records ..."
sudo docker exec seafile $LATEST/seahub.sh python-env $LATEST/seahub/manage.py clear_invalid_repo_data 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE || RC_REPO=$?
log "clear_invalid_repo_data rc=$RC_REPO"
log "END:" $(date "+%F %H:%M:%S"); log ""
if [ "$RC_FSCK$RC_GC$RC_SESS$RC_REPO" = "0000" ]; then
    log "Seafile storage maintenance complete!"; log ""
    exit 0
else
    log "Seafile storage maintenance CON ERRORES (fsck=$RC_FSCK gc=$RC_GC sess=$RC_SESS repo=$RC_REPO)"; log ""
    exit 1
fi
