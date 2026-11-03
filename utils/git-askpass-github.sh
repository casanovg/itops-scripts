#!/bin/bash
#
# GIT_ASKPASS helper for GitHub HTTPS remotes.
# Reads the credentials stored by utils/git-update-id.sh.
#
# TODO: replace this with SSH deploy keys or a proper credential helper.
#       The files are only obfuscated with a fixed OpenSSL passphrase.
#
set -u

case "${1:-}" in
    *[Uu]sername*) file="$HOME/.github-usr" ;;
    *[Pp]assword*) file="$HOME/.github-pwd" ;;
    *) exit 1 ;;
esac

[ -r "$file" ] || exit 1

openssl aes-256-cbc -d -pbkdf2 -pass pass:' ' -in "$file" 2>/dev/null \
    | tr -d '\r\n'
