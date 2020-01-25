#!/bin/sh

#
# Install Seafile server
# ===========================
# 2020-01-25 Gustavo Casanova
#

SEAFILE_SERVER_LINK="https://download.seadrive.org/seafile-server_7.0.5_x86-64.tar.gz"
PYTHON_VER="2.7.17"
PYTHON_LINK="https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz"
SEAFILE_DIR="/opt/seafile"
SOURCE_DIR="/usr/src"
USR="netbackup"
GRP="wheel"

echo ""
echo "Starting Seafile server installation ..."
echo ""

# if [ 1 == 2 ]; then

# Creating install directory
sudo rm -rf $SEAFILE_DIR 
sudo mkdir $SEAFILE_DIR
sudo chown -R $USR:$GRP $SEAFILE_DIR  

# Seafile server download
cd ~
wget $SEAFILE_SERVER_LINK

# Moving software to directory
mv seafile-server_* $SEAFILE_DIR
cd $SEAFILE_DIR

# After moving seafile-server_* to this directory
tar -xzf seafile-server_*
mkdir installed
mv seafile-server_* installed

# Showing new directory tree
cd ..
tree seafile -L 2

# fi

# Install Python 2.7 ...
sudo dnf -y install gcc openssl-devel bzip2-devel make expect
echo ""
#sudo mkdir $SOURCE_DIR
#sudo chown -R $USR:$GRP $SOURCE_DIR
cd $SOURCE_DIR
sudo wget $PYTHON_LINK
sudo tar xzf Python-$PYTHON_VER.tgz
cd Python-$PYTHON_VER
sudo ./configure --enable-optimizations 
sudo make altinstall

# Check Python version
echo ""
/usr/local/bin/python2.7 -V
echo ""

# Install PIP
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python2.7 get-pip.py

# Install Python-MySQL connector
sudo dnf install -y python2-protobuf
sudo dnf install python2-mysql
#sudo dnf install -y mysql-connector-python
#sudo dnf install -y mysql-connector-python-cext

# Install nginx web server
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Setup Seafile
cd $SEAFILE_DIR
./setup-seafile-mysql.sh

# Open firewall ports
sudo firewall-cmd --zone=public --permanent --add-port=8082/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# Start Seafile services
./seafile.sh start
