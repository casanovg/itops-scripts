#!/bin/sh

# Synchronize git repository
# ...........................................
# 2019-12-31 gcasanova@hellermanntyton.com.arFOLDER_1="bare-metal"

GIT_REP="itops-scripts"
TXT_COMMIT="Update scripts"
TXT_NO_CHANGES="nothing to commit"

cd ~/"$GIT_REP"

echo ""
echo "Synchronizing the "$GIT_REP" repository ..."
echo

# Get latest origin changes
echo "Getting latest changes from origin ..."
git pull

# Push latest local changes
echo ""
for DIR in $(ls -d -1 */); do
    cd ~/"$GIT_REP"/$DIR
    sleep 1
    echo "Looking for changes in $(pwd) ..."
    git add -A .
done

#git commit -m "Update scripts $(date)"

if [ ! "$(git commit -m "$TXT_COMMIT $(date)" | grep -w "$TXT_NO_CHANGES")" ]; then
    echo "Changes commited, pushing to origin ..."
    git push
else
    echo "Local branch is up to date with origin!"
fi
echo ""
