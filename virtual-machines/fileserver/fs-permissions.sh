#!/bin/sh

# HTA filesystem persmissions
# ......................................
# 2018-04-09 gustavo.casanova@gmail.com

chmod 771 /data/file-server/

chmod 755 /data/file-server/*
chmod 775 /data/file-server/hta-files/*

chmod -R 775 /data/file-server/hta-files/Abastecimiento/Publico
chmod -R 771 /data/file-server/hta-files/Abastecimiento/Restringido

chmod -R 775 /data/file-server/hta-files/Calidad/Publico
chmod -R 771 /data/file-server/hta-files/Calidad/Restringido

chmod -R 775 /data/file-server/hta-files/Comercial/Publico
chmod -R 771 /data/file-server/hta-files/Comercial/Restringido

chmod -R 775 /data/file-server/hta-files/Financiero/Publico
chmod -R 771 /data/file-server/hta-files/Financiero/Restringido

chmod -R 775 /data/file-server/hta-files/Logistica/Publico
chmod -R 771 /data/file-server/hta-files/Logistica/Restringido

chmod -R 775 /data/file-server/hta-files/Marketing/Publico
chmod -R 771 /data/file-server/hta-files/Marketing/Restringido

chmod -R 775 /data/file-server/hta-files/RRHH/Publico
chmod -R 771 /data/file-server/hta-files/RRHH/Restringido

chmod -R 775 /data/file-server/hta-files/IT/Publico
chmod -R 771 /data/file-server/hta-files/IT/Restringido

chmod -R 775 /data/file-server/hta-files/Ventas/Publico
chmod -R 771 /data/file-server/hta-files/Ventas/Restringido

# chgrp -R HTARGENTINA\\hta-abastecimiento /data/file-server/hta-files/Abastecimiento
# chgrp -R HTARGENTINA\\hta-calidad /data/file-server/hta-files/Calidad
# chgrp -R HTARGENTINA\\hta-comercial /data/file-server/hta-files/Comercial
# chgrp -R HTARGENTINA\\hta-finanzas /data/file-server/hta-files/Financiero
# chgrp -R HTARGENTINA\\hta-logistica /data/file-server/hta-files/Logistica
# chgrp -R HTARGENTINA\\hta-marketing /data/file-server/hta-files/Marketing
# chgrp -R HTARGENTINA\\hta-rrhh /data/file-server/hta-files/RRHH
# chgrp -R HTARGENTINA\\hta-it /data/file-server/hta-files/IT
# chgrp -R HTARGENTINA\\hta-ventas /data/file-server/hta-files/Ventas

chmod -R 771 /data/file-server/hta-users/*

# chown -R HTARGENTINA\\administrator /data/file-server/hta-users/administrator
# chown -R HTARGENTINA\\aallende /data/file-server/hta-users/aallende
# chown -R HTARGENTINA\\afretes /data/file-server/hta-users/afretes
# chown -R HTARGENTINA\\evizgarra /data/file-server/hta-users/evizgarra
# chown -R HTARGENTINA\\ewada /data/file-server/hta-users/ewada
# chown -R HTARGENTINA\\ext-yllabres /data/file-server/hta-users/ext-yllabres
# chown -R HTARGENTINA\\dpollet /data/file-server/hta-users/dpollet
# chown -R HTARGENTINA\\fledesma /data/file-server/hta-users/fledesma
# chown -R HTARGENTINA\\fpiriz /data/file-server/hta-users/fpiriz
# chown -R HTARGENTINA\\gbasile /data/file-server/hta-users/gbasile
# chown -R HTARGENTINA\\gcasanova /data/file-server/hta-users/gcasanova
# chown -R HTARGENTINA\\gmombelli /data/file-server/hta-users/gmombelli
# chown -R HTARGENTINA\\jacosta /data/file-server/hta-users/jacosta
# chown -R HTARGENTINA\\lbarraza /data/file-server/hta-users/lbarraza
# chown -R HTARGENTINA\\lrodriguez /data/file-server/hta-users/lrodriguez
# chown -R HTARGENTINA\\mghezzi /data/file-server/hta-users/mghezzi
# chown -R HTARGENTINA\\rstillo /data/file-server/hta-users/rstillo
# chown -R HTARGENTINA\\mtello /data/file-server/hta-users/mtello
# chown -R HTARGENTINA\\pgiralt /data/file-server/hta-users/pgiralt
# chown -R HTARGENTINA\\seguridad /data/file-server/hta-users/seguridad
# chown -R HTARGENTINA\\skreimerman /data/file-server/hta-users/skreimerman
# chown -R HTARGENTINA\\vaguirre /data/file-server/hta-users/vaguirre
# chown -R HTARGENTINA\\vazcurra /data/file-server/hta-users/vazcurra
# chown -R HTARGENTINA\\vrodriguez /data/file-server/hta-users/vrodriguez

