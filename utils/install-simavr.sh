#!/bin/sh

# Install simavr
# .......................................
# 2020-07-03  gustavo.casanova@gmail.com

sudo dnf install avr-libc elfutils-libelf-devel freeglut freeglut-devel avr-gcc gcc

cd ~/reposera
git clone https://github.com/buserror/simavr.git simavr
cd simavr/simavr
make

