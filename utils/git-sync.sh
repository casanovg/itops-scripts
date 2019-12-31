#!/bin/sh

# Synchronize git repository
# ...........................................
# 2019-12-31 gcasanova@hellermanntyton.com.arFOLDER_1="bare-metal"
FOLDER_2="fileserver-vm"
FOLDER_3="utils"

GIT_REP="itops-scripts"
TXT_NO_CHANGES="nothing to commit"

cd ~/"$GIT_REP"

# Get latest origin changes
#git pull

# Push latest local changes
for DIR in $(ls -d -1 */); do
    echo "Adding changes from $DIR ..."
    cd ~/"$GIT_REP"/$DIR
    git add -A .
done

if [ ! -z $(git commit -m "Update scripts $(date)" | grep -w "$TXT_NO_CHANGES") ]; then
    #git commit -m "Update scripts $(date)"
    git push
else
    echo "Local branch is up to date with origin ..."
fi
