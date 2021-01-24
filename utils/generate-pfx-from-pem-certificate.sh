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
  echo success
  sudo chown 
else
  echo failed
fi

