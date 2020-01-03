#!/bin/sh

# Update GitHub password
# ...........................................
# 2020-01-03 gcasanova@hellermanntyton.com.ar

echo ""
echo "·········································"
echo "· Please enter your GitHub new password ·"
echo "·········································"
stty_orig=$(stty -g)
stty -echo
read pwd 1>/dev/null
stty $stty_orig
echo "$pwd" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.github-usr
echo ""
echo "#############################################################################"
echo "# ATTENTION! The new GitHub password is:" $pwd
echo "#############################################################################"
echo ""
