#!/bin/sh

# Generate .pfx from Let's Encrypt .pem certificate and key for IIS
# ..................................................................
# 2021-01-24 gustavo.casanova@gmail.com

LETSENCRYPT="/etc/letsencrypt/archive"

if [ $# -eq 0 ] || [ -z "$1" ] || [ ! -d $LETSENCRYPT ]; then
    echo ""
    echo "Usage: generate-pfx-from-pem-certificate.sh <CERTIFICATE_NAME> [version]"
    echo ""
    if [ -z "$(ls -1 $LETSENCRYPT 2>>/dev/null)" ]; then
        echo "Certificates existing on this machine:"
        echo ""
        sudo ls -1 $LETSENCRYPT
    else
        echo "   *** There are no certificates on this machine ***   "
    fi
    echo ""
    exit 1
fi

CERTIFICATE="$1"
VERSION="${2:-1}"

#sudo openssl pkcs12 -export -in $LETSENCRYPT/$CERTIFICATE/fullchain$VERSION.pem -inkey $LETSENCRYPT/$CERTIFICATE/privkey$VERSION.pem -out $CERTIFICATE.pfx -password pass:@A3r0L1n3a$#ArG
sudo openssl pkcs12 -export -in $LETSENCRYPT/$CERTIFICATE/fullchain$VERSION.pem -inkey $LETSENCRYPT/$CERTIFICATE/privkey$VERSION.pem -out $CERTIFICATE.pfx

if [ $? -eq 0 ]; then
  sudo chown $(whoami):$(id -gn $(whoami)) $CERTIFICATE.pfx 
else
  echo
  echo "PFX certificate generation failed, please review \"$LETSENCRYPT/$CERTIFICATE\" path ..."
  echo
fi

