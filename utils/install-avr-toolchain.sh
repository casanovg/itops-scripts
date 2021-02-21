#!/bin/sh

# Build from source and install AVR toolchain
# ............................................
# 2020-10-05 gustavo.casanova@gmail.com

START_SEC=$(date -u +%s)
START_TIME=$(date +"%H:%M - %B %d, %Y")

# Check required permissions
if ! [ $(id -u) = 0 ]; then
   echo
   echo "This script needs to run as root, please use \"sudo $(basename "$0")\"" >&2
   echo
   exit 1
fi

# Install prerequisites
echo
echo "Installing AVR toolchain prerequisites"
echo
apt-get -y install wget make gcc g++ bzip2 git autoconf texinfo git libtool bison flex
apt-get -y install gawk libusb-dev libusb-1.0-0-dev libftdi-dev libftdi1-dev libhidapi-dev swig libbfd-dev 

# Folder settings
TMP_DIR="/tmp"
DOWNLOAD_DIR="$HOME/Downloads"
SRC_DIR="avr-src"
PRF_PATH="/etc/profile.d/avr-toolchain.sh"
AVR_PREFIX="/opt/avr"
SUMMARY_FILE="AVR-INSTALLATION-SUMMARY.txt"

# Optional components selection
BUILD_BINUTILS=1
BUILD_AVR_GCC=1
BUILD_AVR_LIBC=1
BUILD_AVR_GDB=1
BUILD_AVRDUDE=1
BUILD_SIMULAVR=0

# Tools versions
AVR_GCC_VER=8.3.0
AVR_BINUTILS_VER=2.29
AVR_LIBC_VER=2.0.0
AVR_GDB_VER=9.2
AVRDUDE_VER=6.3
SIMULAVR_VER=1.0.0
# System MAKE version used: v4.2.1

# Installation path and environment setup
export AVR_PREFIX
if [ -s $(env | grep 'PATH=$AVR_PREFIX') ] 1>>/dev/null 2>>/dev/null; then
    export PATH=$AVR_PREFIX/bin:$PATH
fi

# Create the download folder and move into it
echo
if [ -d $DOWNLOAD_DIR ]; then
    echo ""
    echo "Download folder set to $DOWNLOAD_DIR/$SRC_DIR"
    mkdir -p $DOWNLOAD_DIR/$SRC_DIR
    cd $DOWNLOAD_DIR/$SRC_DIR
else
    echo "Download folder set to $TMP_DIR/$SRC_DIR"
    mkdir -p $TMP_DIR/$SRC_DIR
    cd $TMP_DIR/$SRC_DIR
fi

# Download AVR Binutils
if [ $BUILD_BINUTILS -eq 1 ]; then
    echo
    echo "Downloading AVR Binutils source ..."
    echo
    if [ ! -f binutils-$AVR_BINUTILS_VER.tar.bz2 ]; then
        wget http://ftp.gnu.org/gnu/binutils/binutils-$AVR_BINUTILS_VER.tar.bz2
    else
        echo "AVR Binutils source already downloaded ..."
	echo
    fi
fi

# Download AVR-GCC
if [ $BUILD_AVR_GCC -eq 1 ]; then
    echo
    echo "Downloading AVR-GCC source ..."
    echo
    if [ ! -f gcc-$AVR_GCC_VER.tar.xz ]; then
        wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-$AVR_GCC_VER/gcc-$AVR_GCC_VER.tar.xz
    else
        echo "AVR-GCC source already downloaded ..."
	echo
    fi
fi

# Download AVR-LibC
if [ $BUILD_AVR_LIBC -eq 1 ]; then
    echo
    echo "Downloading AVR-LibC source ..."
    echo
    if [ ! -f avr-libc-$AVR_LIBC_VER.tar.bz2 ]; then
        wget http://download.savannah.gnu.org/releases/avr-libc/avr-libc-$AVR_LIBC_VER.tar.bz2
    else
        echo "AVR-LibC source already downloaded ..."
	echo
    fi
fi

# Download AVR-GDB
if [ $BUILD_AVR_GDB -eq 1 ]; then
    
    echo
    echo "Downloading AVR-GDB source ..."
    echo
    if [ ! -f gdb-$AVR_GDB_VER.tar.bz2 ]; then
        wget https://ftpmirror.gnu.org/gdb/gdb-$AVR_GDB_VER.tar.xz
    else
        echo "AVR-GDB source already downloaded ..."
	echo
    fi
fi

# Download AVRDUDE
if [ $BUILD_AVRDUDE -eq 1 ]; then
    
    echo
    echo "Downloading AVRDUDE source ..."
    echo
    if [ ! -f avrdude-$AVRDUDE_VER.tar.gz ]; then
        wget https://download.savannah.gnu.org/releases/avrdude/avrdude-$AVRDUDE_VER.tar.gz
    else
        echo "AVRDUDE source already downloaded ..."
	echo
    fi
fi

# Download SimulAVR
if [ $BUILD_SIMULAVR -eq 1 ]; then
    
    echo
    echo "Downloading SimulAVR source ..."
    echo
    if [ ! -f simulavr-$SIMULAVR_VER.tar.gz ]; then
        wget https://download.savannah.nongnu.org/releases/simulavr/simulavr-$SIMULAVR_VER.tar.gz
    else
        echo "SimulAVR source already downloaded ..."
	echo
    fi
fi

# Install AVR Binutils
if [ $BUILD_BINUTILS -eq 1 ]; then
    # Extract
    echo
    echo "Extracting binutils-$AVR_BINUTILS_VER.tar.bz2 ..."
    echo
    tar -xvf binutils-$AVR_BINUTILS_VER.tar.bz2
    # Configure, make and install 
    cd binutils-$AVR_BINUTILS_VER
    mkdir obj-avr
    cd obj-avr
    echo
    echo "Configuring AVR Binutils ..."
    echo
    ../configure --prefix=$AVR_PREFIX --target=avr --disable-nls --disable-werror --enable-install-libbfd
    echo
    echo "Building AVR Binutils ..."
    echo
    make
    echo
    echo "Installing AVR Binutils ..."
    echo
    make install
    cd ../..
    rm -rf binutils-$AVR_BINUTILS_VER
else
    echo "Skipping AVR Binutils ..."
    echo
fi

# Install AVR-GCC
if [ $BUILD_AVR_GCC -eq 1 ]; then
    # Extract
    echo
    echo "Extracting gcc-$AVR_GCC_VER.tar.xz ..."
    echo
    tar -xvf gcc-$AVR_GCC_VER.tar.xz
    # Configure, make and install
    cd gcc-$AVR_GCC_VER
    echo "Downloading avr-gcc prerequisites ..."
    echo
    ./contrib/download_prerequisites
    mkdir obj-avr
    cd obj-avr
    echo
    echo "Configuring AVR-GCC ..."
    echo
    ../configure --prefix=$AVR_PREFIX --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --with-dwarf2
    #../configure --prefix=$AVR_PREFIX --target=avr --enable-languages=c,c++ --disable-nls --disable-libssp --disable-libada --with-dwarf2 --disable-shared --enable-static --enable --enable-mingw-wildcard --enable-plugin --with-gnu-as
    echo
    echo "Building AVR-GCC ..."
    echo
    make
    echo
    echo "Installing AVR-GCC ..."
    echo
    make install
    cd ../..
    rm -rf gcc-$AVR_GCC_VER
else
    echo "Skipping AVR-GCC ..."
    echo
fi

# Install AVR-LibC
if [ $BUILD_AVR_LIBC -eq 1 ]; then
    # Extract
    echo
    echo "Extracting avr-libc-$AVR_LIBC_VER.tar.bz2 ..."
    echo
    tar -xvf avr-libc-$AVR_LIBC_VER.tar.bz2
    # Configure, make and install
    cd avr-libc-$AVR_LIBC_VER
    mkdir obj-avr
    cd obj-avr
    echo
    echo "Configuring AVR-LibC ..."
    echo
    ../configure --prefix=$AVR_PREFIX --build=`./config.guess` --host=avr
    echo
    echo "Building AVR-LibC ..."
    echo
    make
    echo
    echo "Installing AVR-LibC ..."
    echo
    make install
    cd ../..
    rm -rf avr-libc-$AVR_LIBC_VER
else
    echo "Skipping AVR-LibC ..."
    echo
fi

# Install AVR-GDB
if [ $BUILD_AVR_GDB -eq 1 ]; then
    # Extract
    echo
    echo "Extracting gdb-$AVR_GDB_VER.tar.xz ..."
    echo
    tar -xvf gdb-$AVR_GDB_VER.tar.xz
    # Configure, make and install
    cd gdb-$AVR_GDB_VER
    mkdir obj-avr
    cd obj-avr
    echo
    echo "Configuring AVR-GDB ..."
    echo
    ../configure --prefix=$AVR_PREFIX --target=avr
    echo
    echo "Building AVR-GDB ..."
    echo
    make
    echo
    echo "Installing AVR-GDB ..."
    echo
    make install
    cd ../..
    rm -rf gdb-$AVR_GDB_VER
else
    echo "Skipping AVR-GDB ..."
    echo
fi   

# Install AVRDUDE
if [ $BUILD_AVRDUDE -eq 1 ]; then
    # Extract
    echo
    echo "Extracting avrdude-$AVRDUDE_VER.tar.gz ..."
    echo
    tar -xvf avrdude-$AVRDUDE_VER.tar.gz
    # Configure, make and install
    cd avrdude-$AVRDUDE_VER
    mkdir obj-avr
    cd obj-avr
    echo
    echo "Configuring AVRDUDE ..."
    echo
    ../configure --prefix=$AVR_PREFIX --enable-linuxgpio
    echo
    echo "Building AVRDUDE ..."
    echo
    make
    echo
    echo "Installing AVRDUDE ..."
    echo
    make install
    cd ../..
    rm -rf avrdude-$AVRDUDE_VER
else
    echo "Skipping AVRDUDE ..."
    echo
fi

# Install SimulAVR
if [ $BUILD_SIMULAVR -eq 1 ]; then
    # Extract
    echo
    echo "Extracting avrdude-$AVRDUDE_VER.tar.gz ..."
    echo
    tar -xvf simulavr-$SIMULAVR_VER.tar.gz
    # Configure, make and install
    cd simulavr-$SIMULAVR_VER
    mkdir obj-avr
    cd obj-avr
    echo
    echo "Configuring SimulAVR ..."
    echo
    ../configure --prefix=$AVR_PREFIX --with-bfd=/opt/avr/bin
    echo
    echo "Building SimulAVR ..."
    echo
    make
    echo
    echo "Installing SimulAVR ..."
    echo
    make install
    cd ../..
    rm -rf simulavr-$SIMULAVR_VER
else
    echo "Skipping SimulAVR ..."
    echo
fi

# Check AVR-GCC installation
echo
echo "Checking AVR-GCC version ..."
echo
avr-gcc --version

# Add the AVR toolchain folders to the PATH environment
echo "#!/bin/sh" > $PRF_PATH
echo "#" >> $PRF_PATH
echo "# AVR toolchain system-wide path" >> $PRF_PATH
echo "#" >> $PRF_PATH
echo "PATH=$AVR_PREFIX/bin:\$PATH" >> $PRF_PATH
echo "export PATH" >> $PRF_PATH
echo "" >> $PRF_PATH

echo "................................................................................"
echo "Please run these commands to add the AVR toolchain folders to the PATH variable:"
echo "     PATH=$AVR_PREFIX/bin:\$PATH"
echo "     export PATH"
echo "This will no longer be necessary after your next reboot as the path was added to:"
echo "     \"$PRF_PATH\""
echo "................................................................................"

END_SEC=$(date -u +%s)
END_TIME=$(date +"%H:%M - %B %d, %Y")

TIME_LAPSE=$((END_SEC-START_SEC))

echo > $SUMMARY_FILE
echo "INSTALL AVR TOOLCHAIN" >> $SUMMARY_FILE
echo >> $SUMMARY_FILE
echo "Built tools:" >> $SUMMARY_FILE
echo "------------" >> $SUMMARY_FILE
if [ $BUILD_BINUTILS -eq 1 ];then echo "* AVR Binutils"; fi >> $SUMMARY_FILE
if [ $BUILD_AVR_GCC -eq 1 ];then echo "* AVR-GCC"; fi >> $SUMMARY_FILE
if [ $BUILD_AVR_LIBC -eq 1 ];then echo "* AVR-LibC"; fi >> $SUMMARY_FILE
if [ $BUILD_AVR_GDB -eq 1 ];then echo "* AVR-GDB"; fi >> $SUMMARY_FILE
if [ $BUILD_AVRDUDE -eq 1 ];then echo "* AVRDUDE"; fi >> $SUMMARY_FILE
if [ $BUILD_SIMULAVR -eq 1 ];then echo "* SimulAVR"; fi >> $SUMMARY_FILE

echo >> $SUMMARY_FILE
echo "Start time: $START_TIME" >> $SUMMARY_FILE
echo "  End time: $END_TIME" >> $SUMMARY_FILE
echo >> $SUMMARY_FILE
echo "Running time: $(($TIME_LAPSE / 3600)) hours, $((($TIME_LAPSE / 60) % 60)) minutes and $(($TIME_LAPSE % 60)) seconds." >> $SUMMARY_FILE
echo >> $SUMMARY_FILE

cat $SUMMARY_FILE

