#!/bin/sh

# Clear nginx cache
# ......................................
# 2020-02-09 gustavo.casanova@gmail.com

curl -X PURGE -D - "https://cloud.hellermanntyton.ar/*"

