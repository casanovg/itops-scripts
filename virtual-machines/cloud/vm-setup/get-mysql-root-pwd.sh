echo "$(cat ~/.mysql-root-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')"
