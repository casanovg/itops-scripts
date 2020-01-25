#!/bin/sh

# Synchronize git repository *
# ...........................................
# NOTES: Use git-update-id.sh to create or
# *****  update your GitHub credentials.
#        You also may need run:
# git config --global credential.helper store
#        before using this script 
# ...........................................
# 2019-12-31 gcasanova@hellermanntyton.com.ar

source ~/itops-scripts/common/set-env.sh

#GIT_REP="itops-scripts"
#COMMON_SCRIPTS="common"
#PHY_SVR_SCRIPTS="bare-metal"
#FILES_VM_SCRIPTS="fileserver-vm"
#UTILS_SCRIPTS="utils"

if [ ! -f ~/.github-usr ] || [ ! -f ~/.github-pwd ]; then
        ~/"$GIT_REP"/"$UTILS_SCRIPTS"/git-update-id.sh
fi


GITHUBREP="$(git config --get remote.origin.url)"
GITHUBUSR="$(cat ~/.github-usr | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ' 1>>/dev/null 2>>/dev/null)"
GITHUBPWD="$(cat ~/.github-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ' 1>>/dev/null 2>>/dev/null)"

cd ~/"$GIT_REP" || return

TXT_COMMIT="Update scripts"
TXT_NO_CHANGES="nothing to commit"

echo ""
echo "Synchronizing the "$GIT_REP" repository ..."
echo

# Get latest origin changes
echo "Getting latest changes from origin ..."
git pull

# Push latest local changes
echo ""
for DIR in $(ls -d -1 */); do
    cd ~/"$GIT_REP"/"$DIR" || return
    sleep 1
    echo "Looking for changes in $(pwd) ..."
    git add -A .
done

#git commit -m "Update scripts $(date)"

if [ ! "$(git commit -m "$TXT_COMMIT $(date)" | grep -w "$TXT_NO_CHANGES")" ]; then
    echo "Changes commited, pushing to origin ..."
    #git push https://$GITHUBUSR:$GITHUBPWD@$GITHUBREP HEAD
    git push "$GITHUBREP" HEAD
else
    echo ""
    echo "Local branch is up to date with origin!"
fi
echo ""
