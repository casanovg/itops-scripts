#!/bin/sh

# Configuration Worker for Flockpool
# ...................................
# 2022-02-22 Worker's union

POOL_URL="us.flockpool.com:5555"
POOL_USR="RBxEzPJfEzobwa1e8aoymm64cGWf1YGwZx"

HOST_NAME=$(awk -F= '/PRETTY/ {print $2}' /etc/machine-info)

if [ ! -f ~/.flockpool-pwd ]; then
	echo ""
	echo "**************************************************************"
	echo "*                                                            *"
	echo "* [[[[ Flockpool password not set, creating it ]]]]          *"
	echo "*                                                            *"
	echo "* ATTENTION! If this is NOT THE FIRST worker in your pool,   *"
        echo "* replace the \".flockpool-pwd\" file in your home directory   *"
	echo "* with the first worker you created's password file ...      *"
	echo "*                                                            *"
	echo "**************************************************************"
        $(echo openssl rand -base64 16) > ~/.flockpool-pwd
fi

POOL_PWD="$(cat ~/.flockpool-pwd)"

echo "{" > $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "    \"autosave\": true," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "    \"cpu\": true," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "    \"opencl\": false," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "    \"cuda\": false," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "    \"pools\": [" >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "        {" >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"coin\": null," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"algo\": \"ghostrider\"," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"url\": \"$POOL_URL\"," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"user\": \"$POOL_USR.${HOST_NAME#CW-}-XMRig\"," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"pass\": \"$POOL_PWD\"," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"tls\": true," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"keepalive\": false," >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "            \"nicehash\": false" >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "        }" >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "    ]" >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "}" >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG
echo "" >> $WORKER_BAS/$WORKER_DIR/$WORKER_CFG

