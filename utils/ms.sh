#!/bin/sh

# Mailsend script
# ........................................................
# NOTE: This script depends on mailsend:
#       $ opkg update && opkg install libopenssl mailsend
# ........................................................
# 2021-02-14 gustavo.casanova@gmail.com


source /root/.mail-settings

# Please set the following variables om a separate
# ".mail-settings" file before running this script:
#
#    MAIL_TO="recipient@recipient-domain.com"
#    MAIL_FROM="root@your_device"
#    MAIL_NAME="Your Name"
#    MAIL_USER="your_mailbox@domain.com"
#    MAIL_PASS="your-appl-passwd"

MY_IP_URL="checkip.amazonaws.com"
LOG_PATH="/var/log/cloudflare-updates.log"

MAIL_SMTP="smtp.gmail.com"
MAIL_PORT="587"
MAIL_OPTS="-starttls -auth"
MAIL_SUBJ="IP Report @ $(date +"%Y-%m-%d %H:%M:%S")"
MAIL_ENCD="-cs \"iso-8859-1\" -enc-type \"8bit\""
MAIL_MESG="External IP address: $(curl -s $MY_IP_URL 2>>/dev/null)"

mailsend -smtp "$(echo $MAIL_SMTP)" \
         -port "$(echo $MAIL_PORT)" \
         $(echo $MAIL_OPTS) \
         -t "$(echo $MAIL_TO)" \
         -f "$(echo $MAIL_FROM)" \
         -name "$(echo $MAIL_NAME)" \
         -user "$(echo $MAIL_USER)" \
         -pass "$(echo $MAIL_PASS)" \
         -sub "$(echo $MAIL_SUBJ)" \
         -M "$(echo $MAIL_MESG)" \
         $(echo $MAIL_ENCD) \
         $(if [ -f "$LOG_PATH" ]; then echo "-attach $LOG_PATH"; fi)
