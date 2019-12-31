#!/bin/sh

# Synchronize git repository
# ...........................................
# 2019-12-31 gcasanova@hellermanntyton.com.ar

GIT_REP="itops-scripts"
TXT_NO_CHANGES="nothing to commit"

cd ~/"$GIT_REP"

# Get latest origin changes
git pull

# Push latest local changes
git add -A .
if [ ! -z $(git commit -m "Update scripts $(date)" | grep -w "$TXT_NO_CHANGES") ]; then
    git push
else
    echo "Local branch is up to date with origin ... "
fi
