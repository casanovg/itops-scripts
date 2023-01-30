#!/bin/sh

# HTA filesystem structure & permissions
# .......................................
# 2018-03-16 gustavo.casanova@gmail.com

if ! (test -d /data/file-server/) then mkdir -p /data/file-server/; fi
chmod 771 /data/file-server/
if ! (test -d /data/file-server/hta-files) then mkdir -p /data/file-server/hta-files; fi
if ! (test -d /data/file-server/hta-users) then mkdir -p /data/file-server/hta-users; fi
chmod 755 /data/file-server/*
if ! (test -d /data/file-server/hta-files/Abastecimiento) then mkdir -p /data/file-server/hta-files/Abastecimiento; fi
if ! (test -d /data/file-server/hta-files/Calidad) then mkdir -p /data/file-server/hta-files/Calidad; fi
if ! (test -d /data/file-server/hta-files/Comercial) then mkdir -p /data/file-server/hta-files/Comercial; fi
if ! (test -d /data/file-server/hta-files/Financiero) then mkdir -p /data/file-server/hta-files/Financiero; fi
if ! (test -d /data/file-server/hta-files/Logistica) then mkdir -p /data/file-server/hta-files/Logistica; fi
if ! (test -d /data/file-server/hta-files/Marketing) then mkdir -p /data/file-server/hta-files/Marketing; fi
if ! (test -d /data/file-server/hta-files/RRHH) then mkdir -p /data/file-server/hta-files/RRHH; fi
if ! (test -d /data/file-server/hta-files/IT) then mkdir -p /data/file-server/hta-files/IT; fi
if ! (test -d /data/file-server/hta-files/Ventas) then mkdir -p /data/file-server/hta-files/Ventas; fi
chmod 775 /data/file-server/hta-files/*
if ! (test -d /data/file-server/hta-files/Abastecimiento/Publico) then mkdir -p /data/file-server/hta-files/Abastecimiento/Publico; fi
if ! (test -d /data/file-server/hta-files/Abastecimiento/Restringido) then mkdir -p /data/file-server/hta-files/Abastecimiento/Restringido; fi
chmod -R 775 /data/file-server/hta-files/Abastecimiento/Publico
chmod -R 771 /data/file-server/hta-files/Abastecimiento/Restringido
if ! (test -d /data/file-server/hta-files/Calidad/Publico) then mkdir -p /data/file-server/hta-files/Calidad/Publico; fi
if ! (test -d /data/file-server/hta-files/Calidad/Restringido) then mkdir -p /data/file-server/hta-files/Calidad/Restringido; fi
chmod -R 775 /data/file-server/hta-files/Calidad/Publico
chmod -R 771 /data/file-server/hta-files/Calidad/Restringido
if ! (test -d /data/file-server/hta-files/Comercial/Publico) then mkdir -p /data/file-server/hta-files/Comercial/Publico; fi
if ! (test -d /data/file-server/hta-files/Comercial/Restringido) then mkdir -p /data/file-server/hta-files/Comercial/Restringido; fi
chmod -R 775 /data/file-server/hta-files/Comercial/Publico
chmod -R 771 /data/file-server/hta-files/Comercial/Restringido
if ! (test -d /data/file-server/hta-files/Financiero/Publico) then mkdir -p /data/file-server/hta-files/Financiero/Publico; fi
if ! (test -d /data/file-server/hta-files/Financiero/Restringido) then mkdir -p /data/file-server/hta-files/Financiero/Restringido; fi
chmod -R 775 /data/file-server/hta-files/Financiero/Publico
chmod -R 771 /data/file-server/hta-files/Financiero/Restringido
if ! (test -d /data/file-server/hta-files/Logistica/Publico) then mkdir -p /data/file-server/hta-files/Logistica/Publico; fi
if ! (test -d /data/file-server/hta-files/Logistica/Restringido) then mkdir -p /data/file-server/hta-files/Logistica/Restringido; fi
chmod -R 775 /data/file-server/hta-files/Logistica/Publico
chmod -R 771 /data/file-server/hta-files/Logistica/Restringido
if ! (test -d /data/file-server/hta-files/Marketing/Publico) then mkdir -p /data/file-server/hta-files/Marketing/Publico; fi
if ! (test -d /data/file-server/hta-files/Marketing/Restringido) then mkdir -p /data/file-server/hta-files/Marketing/Restringido; fi
chmod -R 775 /data/file-server/hta-files/Marketing/Publico
chmod -R 771 /data/file-server/hta-files/Marketing/Restringido
if ! (test -d /data/file-server/hta-files/RRHH/Publico) then mkdir -p /data/file-server/hta-files/RRHH/Publico; fi
if ! (test -d /data/file-server/hta-files/RRHH/Restringido) then mkdir -p /data/file-server/hta-files/RRHH/Restringido; fi
chmod -R 775 /data/file-server/hta-files/RRHH/Publico
chmod -R 771 /data/file-server/hta-files/RRHH/Restringido
if ! (test -d /data/file-server/hta-files/IT/Publico) then mkdir -p /data/file-server/hta-files/IT/Publico; fi
if ! (test -d /data/file-server/hta-files/IT/Restringido) then mkdir -p /data/file-server/hta-files/IT/Restringido; fi
chmod -R 775 /data/file-server/hta-files/IT/Publico
chmod -R 771 /data/file-server/hta-files/IT/Restringido
if ! (test -d /data/file-server/hta-files/Ventas/Publico) then mkdir -p /data/file-server/hta-files/Ventas/Publico; fi
if ! (test -d /data/file-server/hta-files/Ventas/Restringido) then mkdir -p /data/file-server/hta-files/Ventas/Restringido; fi
chmod -R 775 /data/file-server/hta-files/Ventas/Publico
chmod -R 771 /data/file-server/hta-files/Ventas/Restringido
chgrp -R HTARGENTINA\\hta-abastecimiento /data/file-server/hta-files/Abastecimiento
chgrp -R HTARGENTINA\\hta-calidad /data/file-server/hta-files/Calidad
chgrp -R HTARGENTINA\\hta-comercial /data/file-server/hta-files/Comercial
chgrp -R HTARGENTINA\\hta-finanzas /data/file-server/hta-files/Financiero
chgrp -R HTARGENTINA\\hta-logistica /data/file-server/hta-files/Logistica
chgrp -R HTARGENTINA\\hta-marketing /data/file-server/hta-files/Marketing
chgrp -R HTARGENTINA\\hta-rrhh /data/file-server/hta-files/RRHH
chgrp -R HTARGENTINA\\hta-it /data/file-server/hta-files/IT
chgrp -R HTARGENTINA\\hta-ventas /data/file-server/hta-files/Ventas
if ! (test -d /data/file-server/hta-users/administrator) then mkdir -p /data/file-server/hta-users/administrator; fi
if ! (test -d /data/file-server/hta-users/afretes) then mkdir -p /data/file-server/hta-users/afretes; fi
if ! (test -d /data/file-server/hta-users/dpollet) then mkdir -p /data/file-server/hta-users/dpollet; fi
if ! (test -d /data/file-server/hta-users/evizgarra) then mkdir -p /data/file-server/hta-users/evizgarra; fi
if ! (test -d /data/file-server/hta-users/ewada) then mkdir -p /data/file-server/hta-users/ewada; fi
if ! (test -d /data/file-server/hta-users/ext-yllabres) then mkdir -p /data/file-server/hta-users/ext-yllabres; fi
if ! (test -d /data/file-server/hta-users/fledesma) then mkdir -p /data/file-server/hta-users/fledesma; fi
if ! (test -d /data/file-server/hta-users/fpiriz) then mkdir -p /data/file-server/hta-users/fpiriz; fi
if ! (test -d /data/file-server/hta-users/gmombelli) then mkdir -p /data/file-server/hta-users/gmombelli; fi
if ! (test -d /data/file-server/hta-users/gbasile) then mkdir -p /data/file-server/hta-users/gbasile; fi
if ! (test -d /data/file-server/hta-users/gcasanova) then mkdir -p /data/file-server/hta-users/gcasanova; fi
if ! (test -d /data/file-server/hta-users/jacosta) then mkdir -p /data/file-server/hta-users/jacosta; fi
if ! (test -d /data/file-server/hta-users/lbarraza) then mkdir -p /data/file-server/hta-users/lbarraza; fi
if ! (test -d /data/file-server/hta-users/lrodriguez) then mkdir -p /data/file-server/hta-users/lrodriguez; fi
if ! (test -d /data/file-server/hta-users/mghezzi) then mkdir -p /data/file-server/hta-users/mghezzi; fi
if ! (test -d /data/file-server/hta-users/mtello) then mkdir -p /data/file-server/hta-users/mtello; fi
if ! (test -d /data/file-server/hta-users/rstillo) then mkdir -p /data/file-server/hta-users/rstillo; fi
if ! (test -d /data/file-server/hta-users/seguridad) then mkdir -p /data/file-server/hta-users/seguridad; fi
if ! (test -d /data/file-server/hta-users/skreimerman) then mkdir -p /data/file-server/hta-users/skreimerman; fi
if ! (test -d /data/file-server/hta-users/vaguirre) then mkdir -p /data/file-server/hta-users/vaguirre; fi
if ! (test -d /data/file-server/hta-users/vazcurra) then mkdir -p /data/file-server/hta-users/vazcurra; fi
if ! (test -d /data/file-server/hta-users/vrodriguez) then mkdir -p /data/file-server/hta-users/vrodriguez; fi
chmod -R 751 /data/file-server/hta-users/*
chown -R HTARGENTINA\\administrator /data/file-server/hta-users/administrator
chown -R HTARGENTINA\\afretes /data/file-server/hta-users/afretes
chown -R HTARGENTINA\\dpollet /data/file-server/hta-users/dpollet
chown -R HTARGENTINA\\evizgarra /data/file-server/hta-users/evizgarra
chown -R HTARGENTINA\\ewada /data/file-server/hta-users/ewada
chown -R HTARGENTINA\\ext-yllabres /data/file-server/hta-users/ext-yllabres
chown -R HTARGENTINA\\fledesma /data/file-server/hta-users/fledesma
chown -R HTARGENTINA\\fpiriz /data/file-server/hta-users/fpiriz
chown -R HTARGENTINA\\gbasile /data/file-server/hta-users/gbasile
chown -R HTARGENTINA\\gcasanova /data/file-server/hta-users/gcasanova
chown -R HTARGENTINA\\gmombelli /data/file-server/hta-users/gmombelli
chown -R HTARGENTINA\\jacosta /data/file-server/hta-users/jacosta
chown -R HTARGENTINA\\lbarraza /data/file-server/hta-users/lbarraza
chown -R HTARGENTINA\\lrodriguez /data/file-server/hta-users/lrodriguez
chown -R HTARGENTINA\\mghezzi /data/file-server/hta-users/mghezzi
chown -R HTARGENTINA\\mtello /data/file-server/hta-users/mtello
chown -R HTARGENTINA\\rstillo /data/file-server/hta-users/rstillo
chown -R HTARGENTINA\\seguridad /data/file-server/hta-users/seguridad
chown -R HTARGENTINA\\skreimerman /data/file-server/hta-users/skreimerman
chown -R HTARGENTINA\\vaguirre /data/file-server/hta-users/vaguirre
chown -R HTARGENTINA\\vazcurra /data/file-server/hta-users/vazcurra
chown -R HTARGENTINA\\vrodriguez /data/file-server/hta-users/vrodriguez


# HTARGENTINA\administrator
# HTARGENTINA\guest
# HTARGENTINA\krbtgt
# HTARGENTINA\gcasanova
# HTARGENTINA\fpiriz
# HTARGENTINA\mbaldo
# HTARGENTINA\vazcurra
# HTARGENTINA\afretes
# HTARGENTINA\gmombelli
# HTARGENTINA\vrodriguez
# HTARGENTINA\lbarraza
# HTARGENTINA\evizgarra
# HTARGENTINA\rstillo
# HTARGENTINA\mtello
# HTARGENTINA\vaguirre
# HTARGENTINA\mghezzi
# HTARGENTINA\ewada
# HTARGENTINA\dpollet
# HTARGENTINA\skreimerman
# HTARGENTINA\fledesma
# HTARGENTINA\aallende
# HTARGENTINA\pgiralt
# HTARGENTINA\lrodriguez
# HTARGENTINA\jacosta
# HTARGENTINA\seguridad
# HTARGENTINA\gbasile
# HTARGENTINA\ext-yllabres
