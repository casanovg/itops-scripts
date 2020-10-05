#!/bin/sh

# Build from source and install AVR toolchain
# ...........................................
# 2020-10-05 gustavo.casanova@gmail.com


# Install prerequisites
sudo apt-get install wget make gcc g++ bzip2 git autoconf texinfo git

# Installation path and environment setup
export AVR_PREFIX=/opt/avr
if [ -s $(env | grep 'PATH=$AVR_PREFIX') ] 1>>/dev/null 2>>/dev/null; then
    export PATH=$AVR_PREFIX/bin:$PATH
fi

DOWNLOAD_DIR="$HOME/Downloads"
SRC_DIR="avr-src"

AVR_GCC_VER=8.3.0
AVR_BINUTILS_VER=2.29
AVR_LIBC_VER=2.0.0
# AVRDUDE_VER=6.3
# MAKE_VER=4.2.1

# Create download folders
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

# Download AVR Binutils
echo
echo "AVR Binutils ..."
echo
if [ ! -f binutils-$AVR_BINUTILS_VER.tar.bz2 ]; then
    wget http://ftp.gnu.org/gnu/binutils/binutils-$AVR_BINUTILS_VER.tar.bz2
else
    echo "Already downloaded ..."
fi

# Download AVR-GCC
echo
echo "AVR-GCC ..."
echo
if [ ! -f gcc-$AVR_GCC_VER.tar.xz ]; then
    wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$AVR_GCC_VER/gcc-$AVR_GCC_VER.tar.xz
else
    echo "Already downloaded ..."
fi

# Download AVR-LibC
echo
echo "AVR LibC ..."
echo
if [ ! -f avr-libc-$AVR_LIBC_VER.tar.bz2 ]; then
    wget http://download.savannah.gnu.org/releases/avr-libc/avr-libc-$AVR_LIBC_VER.tar.bz2
else
    echo "Already downloaded ..."
fi

# Extract AVR Binutils
echo
echo "Extracting binutils-$AVR_BINUTILS_VER.tar.bz2 ..."
echo
tar -xvf binutils-$AVR_BINUTILS_VER.tar.bz2

# Extract AVR-GCC
echo
echo "Extracting gcc-$AVR_GCC_VER.tar.xz ..."
echo
tar -xvf gcc-$AVR_GCC_VER.tar.xz

# Extract AVR-LibC
echo
echo "Extracting avr-libc-$AVR_LIBC_VER.tar.bz2 ..."
echo
tar -xvf avr-libc-$AVR_LIBC_VER.tar.bz2

# Configure, make and install AVR Binutils
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
rm -rf binutils-$AVR_BINUTILS_VER

# Configure, make and install AVR-GCC
echo
echo "Configuring, making and installing AVR-GCC ..."
echo
mkdir gcc-build
cd gcc-$AVR_GCC_VER
./contrib/download_prerequisites
cd ../gcc-build
../gcc-$AVR_GCC_VER/configure --prefix=$AVR_PREFIX --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2
make
sudo make install
cd ..
rm -rf gcc-build
rm -rf gcc-$AVR_GCC_VER

# Configure, make and install AVR-LibC
echo
echo "Configuring, making and installing AVR-LibC ..."
echo
cd avr-libc-$AVR_LIBC_VER
./configure --prefix=$AVR_PREFIX --build=`./config.guess` --host=avr
make
sudo make install
cd ..
rm -rf avr-libc-$AVR_LIBC_VER

echo
echo "Checking AVR-GCC version ..."
avr-gcc --version
echo

# Add the AVR toolchain folders to the PATH environment
if [ -z $(cat ~/.bashrc | grep $AVR_PREFIX/bin) ]; then
    echo >> ~/.bashrc
    echo "........................................................" >> ~/.bashrc
    echo "Start of section added during AVR toolchain installation" >> ~/.bashrc
    echo >> ~/.bashrc
    echo "PATH=$AVR_PREFIX/bin:$PATH" >> ~/.bashrc
    echo "export PATH" >> ~/.bashrc
    echo >> ~/.bashrc
    echo "End of section added during AVR toolchain installation  " >> ~/.bashrc
    echo "........................................................" >> ~/.bashrc
    echo >> ~/.bashrc
fi

echo
echo "Please run these commands to add the AVR toolchain folders to the PATH environment variable:"
echo
echo "PATH=$AVR_PREFIX/bin:\$PATH"
echo "export PATH"
echo
echo "This will no longer be necessary on your next login as these lines were added to your profile .bashrc file."
echo

