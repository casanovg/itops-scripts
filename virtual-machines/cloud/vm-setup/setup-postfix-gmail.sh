#!/bin/sh

# Setup postfix to send mail through Gmail
# .........................................
# 2020-01-25 gustavo.casanova@gmail.com

MY_EMAIL_ADDRESS=itops.hta@gmail.com
MY_EMAIL_PASSWORD=yourpasswordhere
MY_SMTP_SERVER=smtp.gmail.com
MY_SMTP_SERVER_PORT=587
sudo echo "[$MY_SMTP_SERVER]:$MY_SMTP_SERVER_PORT $MY_EMAIL_ADDRESS:$MY_EMAIL_PASSWORD" >> /etc/postfix/password_maps
sudo chmod 600 /etc/postfix/password_maps
sudo unset MY_EMAIL_PASSWORD
sudo history -c
