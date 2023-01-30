#!/bin/sh

# Create a .iso mountable image from any folder
# ..............................................
# 2022-11-16 gustavo.casanova@gmail.com

mkisofs -V LABEL -o filename.iso /source-folder

