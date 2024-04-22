#!/bin/bash

# Synchronize git repository
# ......................................................
# NOTES: Use git-update-id.sh to create or
# =====  update your GitHub credentials.
#        You also may need running:
#        $ git config --global credential.helper store
#        before using this script 
# ......................................................
# 2020-10-13 gustavo.casanova@gmail.com

if [ ! -z "$1" ]; then cd $1; fi

if [ ! $(git rev-parse --is-inside-work-tree 2>>/dev/null) ]; then
    echo
    echo "You are NOT inside a git repository! Please change the current"
    echo "directory to a git folder or specify its path as follows:"
    echo
    echo "git-sync.sh ~/my-repos/my-git-project-folder"
    echo
    exit 1
fi

HERE="$(pwd)"
GIT_REP="$(basename $(git rev-parse --show-toplevel))"

# Check if GitHub user and password are set
if [ ! -f ~/.github-usr ] || [ ! -f ~/.github-pwd ]; then
        ~/"$GIT_REP"/"$UTILS_SCRIPTS"/git-update-id.sh
fi

#cd ~/"$GIT_REP" || return
cd "${HERE%%/$(basename $(git rev-parse --show-toplevel))*}/$(basename $(git rev-parse --show-toplevel))" || return

GITHUBREP="github.com/casanovg/$GIT_REP.git"
GITHUBUSR="$(cat ~/.github-usr | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')"
GITHUBPWD="$(cat ~/.github-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')"

TXT_COMMIT="Update scripts"
TXT_NO_CHANGES="nothing to commit"

CRON_DIR="cron"

echo ""
echo "Synchronizing the "$GIT_REP" repository ..."
echo

# Get the latest origin changes
echo "Getting latest changes from origin ..."
git pull

# Search the latest local changes to commit
echo ""
for DIR in $(ls -d -1 */); do
    #cd ~/"$GIT_REP"/"$DIR" || return
    cd "${HERE%%/$(basename $(git rev-parse --show-toplevel))*}/$(basename $(git rev-parse --show-toplevel))"/"$DIR" || return
    sleep 1
    echo "Looking for changes in $(pwd) ..."
    git add -A .
done

# If there are local changes, commit and push to origin
if [ ! "$(git commit -m "$TXT_COMMIT $(date)" | grep -w "$TXT_NO_CHANGES")" ]; then
    echo "Changes commited, pushing to origin ..."
    git push https://$GITHUBUSR:$GITHUBPWD@$GITHUBREP HEAD
else
    echo ""
    echo "Local branch is up to date with origin!"
fi
echo ""

