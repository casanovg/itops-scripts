#!/bin/sh

# Get External IP address from an external service
# .................................................
# 2021-02-12 gustavo.casanova@gmail.com

# Use one of the available services
#
# checkip.amazonaws.com
# ifconfig.me
# icanhazip.com
# ipecho.net/plain
# ifconfig.co

curl -s ifconfig.me
