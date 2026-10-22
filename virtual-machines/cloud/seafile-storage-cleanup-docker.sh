#!/bin/bash
# Seafile storage maintenance (Docker version)
# Adaptado de itops-scripts/.../seafile-storage-cleanup.sh (binario) a contenedor.
# Parar/arrancar = servicios internos del container (el container sigue up).
# NOTA: fsck+GC en 176GB/3M archivos tarda horas, con servicio caido. Ventana: sab 07:00.

LATEST=/opt/seafile/seafile-server-latest
LOG_PATH="/data/seafile-docker/maintenance-log"
LOG_FILE="Seafile-Maintenance-$(date +%Y-%m-%d).log"
mkdir -p $LOG_PATH
rm -rf $LOG_PATH/* 1>/dev/null 2>/dev/null

log() { echo "$@" 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE; }
log ""; log "Seafile Maintenance Routine (Docker)"; log "==========================="; log ""
log "START:" $(date "+%F %H:%M:%S"); log ""

log "Stopping internal services ..."
sudo docker exec seafile $LATEST/seahub.sh stop 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo docker exec seafile $LATEST/seafile.sh stop 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
log ""
log "Giving the server some time to shut down properly ..."
sleep 20

log "Check and repair libraries ..."
sudo docker exec seafile $LATEST/seaf-fsck.sh --repair 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
log ""
sleep 10

log "Seafile cleanup started ..."
sudo docker exec seafile $LATEST/seaf-gc.sh 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
log ""
sleep 10

log "Clear expired session records ..."
sudo docker exec seafile $LATEST/seahub.sh python-env $LATEST/seahub/manage.py clearsessions 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sleep 10

log "Starting internal services ..."
sudo docker exec seafile $LATEST/seafile.sh start 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo docker exec seafile $LATEST/seahub.sh start 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
log ""

log "Clear outdated library records ..."
sudo docker exec seafile $LATEST/seahub.sh python-env $LATEST/seahub/manage.py clear_invalid_repo_data 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
log "END:" $(date "+%F %H:%M:%S"); log ""
log "Seafile storage maintenance complete!"; log ""
exit:0
