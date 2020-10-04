#!/bin/sh

# Build from source and install AVR toolchain
# ...........................................
# 2020-10-05 gustavo.casanova@gmail.com

# Installation path and environment setup
export AVR_PREFIX=/opt/avr
if [ -s $(env | grep 'PATH=$AVR_PREFIX') 1>>/dev/null 2>>/dev/null ]; then
    export PATH=$AVR_PREFIX/bin:$PATH
fi

DOWNLOAD_DIR="$HOME/Downloads"
SRC_DIR="avr-src"

AVR_GCC_VER=8.3.0
AVR_BINUTILS_VER=2.29
AVR_LIBC_VER=2.0.0
#AVR-GCC 8.3.0 x64
#AVR-Binutils 2.32 x64
#AVR-LibC 2.0.0
#AVRDUDE 6.3 x86
#Make 4.2.1 x64

echo
if [ -d $DOWNLOAD_DIR ]; then
    echo ""
    echo "Downloading source files to $DOWNLOAD_DIR/$SRC_DIR"
    mkdir -p $DOWNLOAD_DIR/$SRC_DIR
    cd $DOWNLOAD_DIR/$SRC_DIR
else
    echo "Downloading source files to $HOME/$SRC_DIR"
    mkdir -p $HOME/$SRC_DIR
    cd $HOME/$SRC_DIR
fi

echo
echo "AVR Binutils ..."
echo
if [ ! -f binutils-$AVR_BINUTILS_VER.tar.bz2 ]; then
    wget http://ftp.gnu.org/gnu/binutils/binutils-$AVR_BINUTILS_VER.tar.bz2
else
    echo "Already downloaded ..."
fi

echo
echo "AVR-GCC ..."
echo
if [ ! -f gcc-$AVR_GCC_VER.tar.xz ]; then
    wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$AVR_GCC_VER/gcc-$AVR_GCC_VER.tar.xz
else
    echo "Already downloaded ..."
fi

echo
echo "AVR LibC ..."
echo
if [ ! -f avr-libc-$AVR_LIBC_VER.tar.bz2 ]; then
    wget http://download.savannah.gnu.org/releases/avr-libc/avr-libc-$AVR_LIBC_VER.tar.bz2
else
    echo "Already downloaded ..."
fi

echo
echo "Extracting binutils-$AVR_BINUTILS_VER.tar.bz2 ..."
echo
tar -xvf binutils-$AVR_BINUTILS_VER.tar.bz2

echo
echo "Extracting gcc-$AVR_GCC_VER.tar.xz ..."
echo
tar -xvf gcc-$AVR_GCC_VER.tar.xz

echo
echo "Extracting avr-libc-$AVR_LIBC_VER.tar.bz2 ..."
echo
tar -xvf avr-libc-$AVR_LIBC_VER.tar.bz2

echo
echo "Configuring, making and installing AVR Binutils ..."
echo
cd binutils-$AVR_BINUTILS_VER
mkdir avr-obj
cd avr-obj
../configure --prefix=$AVR_PREFIX --target=avr --disable-nls
make
sudo make install
cd ../..
# rm -rf binutils-$AVR_BINUTILS_VER

echo
echo "Configuring, making and installing AVR-GCC ..."
echo
mkdir bld-gcc
cd gcc-$AVR_GCC_VER
./contrib/download_prerequisites
cd ../bld-gcc
../gcc-$AVR_GCC_VER/configure --prefix=$AVR_PREFIX --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2
make
sudo make install
cd ..
# rm -rf bld-gcc
# rm gcc-$AVR_GCC_VER

echo
echo "Configuring, making and installing AVR-LiC ..."
echo
cd avr-libc-$AVR_LIBC_VER
./configure --prefix=$AVR_PREFIX --build=`./config.guess` --host=avr
make
sudo make install
cd ..
# rm -rf avr-libc-$AVR_LIBC_VER

echo
echo "Checking AVR-GCC version ..."
avr-gcc --version
echo
