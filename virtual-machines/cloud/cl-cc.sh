#!/bin/sh

#
# Clear nginx cache
# ............................................
# 2020-02-09 gcasanova@hellermanntyton.com.ar
#

curl -X PURGE -D - "https://cloud.htservices.com.ar/*"

