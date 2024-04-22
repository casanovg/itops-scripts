#!/bin/bash

# Fix Seafile after OS upgrade
# ...........................................................
# After an OS upgrade, e.g. from Fedora 36 to 37, Seafile's
# Python dependencies may not update correctly. This causes
# an "Internal Server Error" message in the web application
# as Seahub doesn't start correctly. This script's
# installation sequence fixes it (at least up to Fedora 37).
# ...........................................................
# 2022-11-20 gustavo.casanova@gmail.com

sudo pip3 install --root-user-action=ignore wheel
sudo pip3 install --root-user-action=ignore captcha
sudo pip3 install --root-user-action=ignore mysqlclient
sudo pip3 install --root-user-action=ignore --timeout=3600 Pillow pylibmc captcha jinja2 sqlalchemy psd-tools django-pylibmc django-simple-captcha python3-ldap

