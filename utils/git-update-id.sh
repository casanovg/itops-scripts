#!/bin/sh

# Update GitHub user and password
# ...........................................
# 2020-01-03 gcasanova@hellermanntyton.com.ar

echo ""
echo "·····································"
echo "· Please enter your GitHub username ·"
echo "·····································"
read usr
#stty $stty_orig
#stty_orig=$(stty -g)
echo "$usr" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.github-usr

echo ""
echo "·····································"
echo "· Please enter your GitHub password ·"
echo "·····································"
stty_orig=$(stty -g)
stty -echo
read pwd 1>/dev/null
stty $stty_orig
echo "$pwd" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.github-pwd
echo ""
echo "#############################################################################"
echo "# ATTENTION!"
echo "# Your GitHub user name is: \"$usr\" and your new password: \"$pwd\""
echo "#############################################################################"
echo ""

stty sane
sleep 5
clear
