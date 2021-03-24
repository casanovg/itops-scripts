#!/bin/bash

#
# Generate .pfx from Let's Encrypt .pem certificate and key for IIS
# =================================================================
# 2021-01-24 gcasanova@hellermanntyton.com.ar
#

LETSENCRYPT="/etc/letsencrypt/archive"

if [ $# -eq 0 ] || [ -z "$1" ]
  then
    echo ""
    echo "Usage: generate-pfx-from-pem-certificate.sh <CERTIFICATE_NAME>"
    echo ""
    echo "Certificates existing on this machine:"
    echo ""
    sudo ls -1 $LETSENCRYPT
    echo ""
    exit 1
fi

CERTIFICATE="$1"

sudo openssl pkcs12 -export -in $LETSENCRYPT/$CERTIFICATE/fullchain1.pem -inkey $LETSENCRYPT/$CERTIFICATE/privkey1.pem -out $CERTIFICATE.pfx

if [ $? -eq 0 ]; then
  sudo chown $(whoami):$(id -gn $(whoami)) $CERTIFICATE.pfx 
else
  echo
  echo "PFX certificate generation failed, please review \"$LETSENCRYPT/$CERTIFICATE\" path ..."
  echo
fi

