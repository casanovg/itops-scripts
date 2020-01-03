#!/bin/sh

# Synchronize git repository *
# ...........................................
# NOTE: Use git-update-id-sh to create or
# ***** update your GitHub credentials  
# ...........................................
# 2019-12-31 gcasanova@hellermanntyton.com.ar

source ~/itops-scripts/common/set-env.sh

GITHUBREP="github.com/casanovg/itops-scripts.git"
GITHUBUSR=$(cat ~/.github-usr | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')
GITHUBPWD=$(cat ~/.github-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')

TXT_COMMIT="Update scripts"
TXT_NO_CHANGES="nothing to commit"

cd ~/"$GIT_REP" || return

echo ""
echo "Synchronizing the "$GIT_REP" repository ..."
echo

# Get latest origin changes
echo "Getting latest changes from origin ..."
git pull

# Push latest local changes
echo ""
for DIR in $(ls -d -1 */); do
    cd ~/"$GIT_REP"/$DIR || return
    sleep 1
    echo "Looking for changes in $(pwd) ..."
    git add -A .
done

#git commit -m "Update scripts $(date)"

if [ ! "$(git commit -m "$TXT_COMMIT $(date)" | grep -w "$TXT_NO_CHANGES")" ]; then
    echo "Changes commited, pushing to origin ..."
    #git push
    #git push https://user:pass@yourrepo.com/path HEAD
    git push https://$GITHUBUSR:$GITHUBPWD@$GITHUBREP HEAD
else
    echo ""
    echo "Local branch is up to date with origin!"
fi
echo ""
