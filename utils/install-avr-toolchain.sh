#!/bin/sh

# Build from source and install AVR toolchain
# ............................................
# 2020-10-05 gustavo.casanova@gmail.com

# Check required permissions
if ! [ $(id -u) = 0 ]; then
   echo
   echo "This script need to be run as root, please use \"sudo $(basename "$0")\"" >&2
   echo
   exit 1
fi

# Install prerequisites
echo
echo "Installing AVR toolchain prerequisites"
echo
apt-get -y install wget make gcc g++ bzip2 git autoconf texinfo git libtool

DOWNLOAD_DIR="$HOME/Downloads"
SRC_DIR="avr-src"
PRF_PATH="/etc/profile.d/avr-toolchain.sh"

AVR_PREFIX="/opt/avr"
AVR_GCC_VER=8.3.0
AVR_BINUTILS_VER=2.29
AVR_LIBC_VER=2.0.0
AVR_GDB_VER=9.2
AVRDUDE_VER=6.3
#SIMULAVR_VER=1.0.0
#MAKE_VER=4.2.1

# Optional components selection
BUILD_GDB=0
BUILD_AVRDUDE=0
BUILD_SIMULAVR=0

# Installation path and environment setup
export AVR_PREFIX
if [ -s $(env | grep 'PATH=$AVR_PREFIX') ] 1>>/dev/null 2>>/dev/null; then
    export PATH=$AVR_PREFIX/bin:$PATH
fi

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

# Download AVR GDB
if [ $BUILD_GDB -eq 1 ]; then
    echo
    echo "AVR GDB ..."
    echo
    if [ ! -f gdb-$AVR_GDB_VER.tar.bz2 ]; then
        wget https://ftpmirror.gnu.org/gdb/gdb-$AVR_GDB_VER.tar.xz
    else
        echo "Already downloaded ..."
    fi
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

# Extract AVR-GDB
echo
echo "Extracting gdb-$AVR_GDB_VER.tar.xz ..."
echo
tar -xvf gdb-$AVR_GDB_VER.tar.xz

# Configure, make and install AVR Binutils
echo
echo "Configuring, making and installing AVR Binutils ..."
echo
cd binutils-$AVR_BINUTILS_VER
mkdir obj-avr
cd obj-avr
../configure --prefix=$AVR_PREFIX --target=avr --disable-nls --disable-werror
make
make install
cd ../..
rm -rf binutils-$AVR_BINUTILS_VER

# Configure, make and install AVR-GCC
echo
echo "Configuring, making and installing AVR-GCC ..."
echo
cd gcc-$AVR_GCC_VER
echo "Downloading avr-gcc prerequisites ..."
echo
./contrib/download_prerequisites
mkdir obj-avr
cd obj-avr
../configure --prefix=$AVR_PREFIX --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2
#../configure --prefix=$AVR_PREFIX --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --disable-libada --with-dwarf2 --disable-shared --enable-static --enable --enable-mingw-wildcard --enable-plugin --with-gnu-as
make
make install
cd ../..
rm -rf gcc-$AVR_GCC_VER

# Configure, make and install AVR-LibC
echo
echo "Configuring, making and installing AVR-LibC ..."
echo
cd avr-libc-$AVR_LIBC_VER
mkdir obj-avr
cd obj-avr
../configure --prefix=$AVR_PREFIX --build=`./config.guess` --host=avr
make
make install
cd ../..
rm -rf avr-libc-$AVR_LIBC_VER

echo
echo "Checking AVR-GCC version ..."
avr-gcc --version
echo

# Download, extract, configure, make and install AVR-GDB
if [ $BUILD_GDB -eq 1 ]; then
    # Download 
    echo
    echo "AVR GDB ..."
    echo
    if [ ! -f gdb-$AVR_GDB_VER.tar.bz2 ]; then
        wget https://ftpmirror.gnu.org/gdb/gdb-$AVR_GDB_VER.tar.xz
    else
        echo "Already downloaded ..."
    fi
    # Extract
    echo
    echo "Extracting gdb-$AVR_GDB_VER.tar.xz ..."
    echo
    tar -xvf gdb-$AVR_GDB_VER.tar.xz
    # Configure, make and install
    echo
    echo "Configuring, making and installing AVR-GDB ..."
    echo
    cd gdb-$AVR_GDB_VER
    mkdir obj-avr
    cd obj-avr
    ../configure --prefix=$AVR_PREFIX --target=avr
    make
    make install
    cd ../..
    rm -rf avr-libc-$AVR_GDB_VER
fi

# Add the AVR toolchain folders to the PATH environment
echo "#!/bin/sh" > $PRF_PATH
echo "#" >> $PRF_PATH
echo "# AVR toolchain system-wide path" >> $PRF_PATH
echo "#" >> $PRF_PATH
echo "PATH=$AVR_PREFIX/bin:\$PATH" >> $PRF_PATH
echo "export PATH" >> $PRF_PATH
echo "" >> $PRF_PATH

echo
echo "Please run these commands to add the AVR toolchain folders to the PATH environment variable:"
echo
echo "PATH=$AVR_PREFIX/bin:\$PATH"
echo "export PATH"
echo
echo "This will no longer be necessary on your next login as the path was added to \"$PRF_PATH\"."
echo

