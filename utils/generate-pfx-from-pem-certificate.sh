#!/bin/bash

#
# Generate .pfx from Let's Encrypt .pem certificate and key for IIS
# =================================================================
# 2021-01-24 gcasanova@hellermanntyton.com.ar
#

LETSENCRYPT="/etc/letsencrypt/archive"
CERTIFICATE="$1"

sudo openssl pkcs12 -export -in $LETSENCRYPT/$CERTIFICATE/fullchain1.pem -inkey $LETSENCRYPT/$CERTIFICATE/privkey1.pem -out $CERTIFICATE.pfx

if [ $? -eq 0 ]; then
  sudo chown $(whoami):$(id -gn $(whoami)) $CERTIFICATE.pfx 
else
  echo
  echo "PFX certificate generation failed, please review \"$LETSENCRYPT/$CERTIFICATE\" path ..."
  echo
fi

