#!/bin/sh

# Asterisk 13 LTS Fedora 23 installation script
# ..............................................
# 2016-03-03 gustavo.casanova@gmail.com

clear;
echo "#################################################";
echo "# Asterisk 13 LTS Fedora 23 Installation Script #";
echo "# ============================================= #";
echo "# v1.0: 2016-03-05                              #";
echo "# ----------------                              #";
echo "# Gustavo Casanova (gustavo.casanova@gmail.com) #";
echo "#################################################";
echo "";
echo "Start time: "`date` >> ~/asterisk-install-time;
#########################
# Environment Variables #
#########################
ASTERISK_UNIX_USR="asteriskpbx";
ASTERISK_MYSQL_USR="asterisk";
ASTERISK_MYSQL_PWD="asterisk";
ASTERISK_MYSQL_MAINDB="asterisk";
ASTERISK_MYSQL_CDRDB="cdrdb";
MYSQL_ROOT_PASSWORD="PASSWORD";
#########################
# End declarations      #
#########################
sleep 3;
uname -a | grep fc23 1>/dev/null 2>/dev/null;
if [ $? -ne 0 ]
then
  echo "   ***********************************************"
  echo "   *     >>> YOUR SYSTEM IS NOT FEDORA 23 <<<    *"
  echo "   * Please contact the adminstrator to get help *"
  echo "   *                Exiting now ...              *"
  echo "   ***********************************************"
  echo ""
  exit 1
fi;
getenforce | grep 'Disabled' 1>/dev/null 2>/dev/null;
if [ $? -ne 0 ]
then
  echo "*************************"
  echo "* Disabling selinux ... *"
  echo "*************************"
  sleep 3
  sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
  echo "."
  echo "********************************************************"
  echo "*    >>> SELINUX DISABLED IN CONFIGURATION FILE <<<    *"
  echo "* Please reboot your computer and relaunch this script *"
  echo "*                       Exiting now ...                *"
  echo "********************************************************"
  echo ""
  exit 1
fi;
echo ".";
echo "*********************************************";
echo "* Creating Asterisk installation folder ... *";
echo "*********************************************";
sleep 3;
mkdir -p /data/asterisk-install;      
echo ".";
cd /data/asterisk-install
echo "*********************************************************";
echo "* Downloading Asterisk 13 and libraries source code ... *";
echo "*********************************************************";
sleep 3;
echo "";
wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz;
wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz;
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz;
echo ".";
echo "**********************************";
echo "* Uncompressing source files ... *";
echo "**********************************";
sleep 3;
tar -zxvf /data/asterisk-install/dahdi-linux-complete-current.tar.gz;
tar -zxvf /data/asterisk-install/libpri-current.tar.gz;
tar -zxvf /data/asterisk-install/asterisk-13-current.tar.gz;
# rm -f /data/asterisk-install/dahdi-linux-complete-current.tar.gz;
# rm -f /data/asterisk-install/libpri-*.tar.gz;
# rm -f /data/asterisk-install/asterisk-13-current.tar.gz;
echo ".";
echo "****************************************************************";
echo "* Updating system and installing Asterisk 13 prerequisites ... *";
echo "****************************************************************";
sleep 3;
dnf -y update;
dnf -y install audiofile-devel;
dnf -y install automake;
dnf -y install bison;
dnf -y install bluez-libs-devel;
dnf -y install caching-nameserver;
dnf -y install corosynclib-devel;
dnf -y install cronie;
dnf -y install cronie-anacron;
dnf -y install crontabs;
dnf -y install doxygen;
dnf -y install expect;
dnf -y install freetds-devel;
dnf -y install gcc;
dnf -y install gcc-c++;
dnf -y install git;
dnf -y install gmime-devel;
dnf -y install gnutls-devel;
dnf -y install gsm-devel;
dnf -y install gtk2-devel;
dnf -y install httpd;
dnf -y install iksemel-devel;
dnf -y install jack-audio-connection-kit-devel;
dnf -y install jansson-devel;
dnf -y install kernel-devel;
dnf -y install kernel-devel-$(uname -r);
dnf -y install libcurl-devel;
dnf -y install libedit-devel;
dnf -y install libical-devel;
dnf -y install libogg-devel;
dnf -y install libresample-devel;
dnf -y install libsqlite3x-devel;
dnf -y install libsrtp-devel;
dnf -y install libtermcap-devel;
dnf -y install libtiff-devel;
dnf -y install libtool;
dnf -y install libtool-ltdl-devel;
dnf -y install libuuid-devel;
dnf -y install libvorbis-devel;
dnf -y install libxml2-devel;
dnf -y install libxslt-devel;
dnf -y install lua-devel;
dnf -y install lynx;
dnf -y install make;
dnf -y install mariadb;
dnf -y install mariadb-devel;
dnf -y install mariadb-server;
dnf -y install mysql-devel;
dnf -y install ncurses-devel;
dnf -y install neon-devel;
dnf -y install net-snmp-devel;
dnf -y install net-tools;
dnf -y install newt-devel;
dnf -y install openldap-devel;
dnf -y install openssl-devel;
dnf -y install php;
dnf -y install php-mbstring;
dnf -y install php-mysql;
dnf -y install php-pear;
dnf -y install php-process;
dnf -y install php-xml;
dnf -y install pjproject-devel;
dnf -y install popt-devel;
dnf -y install portaudio-devel;
dnf -y install postgresql-devel;
dnf -y install psmisc;
dnf -y install python-devel;
dnf -y install radiusclient-ng-devel;
dnf -y install redhat-rpm-config;
dnf -y install sendmail;
dnf -y install sendmail-cf;
dnf -y install sox;
dnf -y install spandsp-devel;
dnf -y install speex-devel;
dnf -y install speexdsp-devel;
dnf -y install sqlite2-devel;
dnf -y install sqlite-devel;
dnf -y install subversion;
dnf -y install tftp-server;
dnf -y install unixODBC-devel;
dnf -y install uuid-devel;
dnf -y install vim;
dnf -y install wget;
echo ".";
echo "****************************************";
echo "* Starting MariaDB database system ... *";
echo "****************************************";
sleep 3;
systemctl start mariadb;
systemctl enable mariadb;
# mysql_secure_installation;
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Set root password?\"
send \"y\r\"
expect \"New password: \"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Re-enter new password: \"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
echo ".";
echo "***********************************************************************";
echo "* Compiling and installing Jansson library for JSON data handling ... *";
echo "***********************************************************************";
sleep 3;
# dnf -y jansson;
cd /data/asterisk-install
git clone https://github.com/akheron/jansson.git;
cd ./jansson;
autoreconf -i;
./configure --prefix=/usr/ --libdir=/usr/lib64;
make;
make install;
echo ".";
echo "*******************************************";
echo "* Installing legacy Pear requirements ... *";
echo "*******************************************";
sleep 3;
pear install Console_Getopt;
echo ".";
echo "**********************************************";
echo "* Compiling and installing DAHDI library ... *";
echo "**********************************************";
sleep 3;
cd /data/asterisk-install/dahdi-linux-complete-*;
make all;
make install;
make config;
echo ".";
echo "***********************************************";
echo "* Compiling and installing LibPRI library ... *";
echo "***********************************************";
sleep 3;
cd /data/asterisk-install/libpri-*;
make;
make install;
echo ".";
echo "**********************************************";
echo "* Compiling and installing PJSIP library ... *";
echo "**********************************************";
sleep 3;
cd /data/asterisk-install;
wget http://www.pjsip.org/release/2.4/pjproject-2.4.tar.bz2
tar -xjvf pjproject-2.4.tar.bz2;
# rm -f pjproject-2.4.tar.bz2;
cd pjproject-2.4*;
CFLAGS='-DPJ_HAS_IPV6=1' ./configure --prefix=/usr --enable-shared --disable-sound\
--disable-resample --disable-video --disable-opencore-amr --libdir=/usr/lib64;
make dep;
make;
make install;
echo ".";
echo "**************************";
echo "* Installing MP3 decoder *";
echo "**************************";
sleep 3;
cd /data/asterisk-install/asterisk-13.*;
/data/asterisk-install/asterisk-13.*/contrib/scripts/get_mp3_source.sh;
echo ".";
echo "***************************************";
echo "* Configuring Asterisk 13 modules ... *";
echo "***************************************";
echo "";
sleep 5;                           
cd /data/asterisk-install/asterisk-13.*;
./configure --libdir=/usr/lib64;
cd ~;
rm -f Asterisk-Modules-Menuselect;
wget -O Asterisk-Modules-Menuselect https://www.dropbox.com/s/u10j7y6smshb6fu/Asterisk-Modules-Menuselect.txt?dl=0;
if [ $? -ne 0 ]
then
  echo "*********************************************"
  echo "*    >>> MODULES FILE DOWNLOAD FAILED <<<   *"
  echo "* Launching manual module configuration ... *"
  echo "*********************************************"
  echo ""
  sleep 3
  make menuselect
  sleep 3
  echo "."
else
  echo "*****************************************"
  echo "*    >>> MODULES FILE DOWNLOADED    <<< *"
  echo "* Launching automatic configuration ... *"
  echo "*****************************************"
  echo ""
  sleep 3
  cd /data/asterisk-install/asterisk-13.*
  make menuselect.makeopts
  mv -f ~/Asterisk-Modules-Menuselect /data/asterisk-install/asterisk-13.*/
  dos2unix Asterisk-Modules-Menuselect
  chmod 744 Asterisk-Modules-Menuselect
  echo ""
  echo "Running Menuselect automatic script, please wait ..."
  echo ""
  source ./Asterisk-Modules-Menuselect
  if [ $? -eq 0 ]
  then
    echo "*****************************************************"
    echo "* Menuselect automatic configuration successful ... *"
    echo "*****************************************************"
    echo ""
    sleep 3
    echo "."
    rm -f Asterisk-Modules-Menuselect
  else
    echo "*********************************************"
    echo "*    >>> MENUSELECT AUTO CONF FAILED <<<    *"
    echo "* Launching manual module configuration ... *"
    echo "*********************************************"
    echo ""
    sleep 3
    make menuselect
    sleep 3
    echo "."
  fi
fi;
echo "********************************************";
echo "* Compiling and installing Asterisk 13 ... *"
echo "********************************************";
sleep 3;
cd /data/asterisk-install/asterisk-13.*;
make;
make install;
make samples;
# make progdocs;
make config;
echo ".";
echo "***************************************";
echo "* Adding Asterisk service account ... *";
echo "***************************************";
sleep 3;
useradd -m $ASTERISK_UNIX_USR;
chown $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /var/run/asterisk;
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /etc/asterisk;
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /var/{lib,log,spool}/asterisk;
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /usr/lib64/asterisk;
echo ".";
echo "************************************";
echo "* Configuring Asterisk service ... *";
echo "************************************";
sleep 3;
cd /data/asterisk-install/asterisk-13.*;
cp -f ./contrib/init.d/rc.redhat.asterisk /etc/init.d/asterisk;
sed -i 's/\(^AST_SBIN=\).*/\AST_SBIN=\/usr\/sbin/' /etc/init.d/asterisk
chmod 755 /etc/init.d/asterisk;
echo ".";
echo "*****************************************************";
echo "* Setting-up Asterisk database on MariaDB RDBMS ... *";
echo "*****************************************************";
sleep 3;
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<QUERY_INPUT
create user '$ASTERISK_MYSQL_USR'@'localhost' identified by '$ASTERISK_MYSQL_PWD';
create database $ASTERISK_MYSQL_MAINDB;
create database $ASTERISK_MYSQL_CDRDB;
GRANT ALL PRIVILEGES ON $ASTERISK_MYSQL_MAINDB.* TO $ASTERISK_MYSQL_USR@localhost IDENTIFIED BY '$ASTERISK_MYSQL_PWD';
GRANT ALL PRIVILEGES ON $ASTERISK_MYSQL_CDRDB.* TO $ASTERISK_MYSQL_USR@localhost IDENTIFIED BY '$ASTERISK_MYSQL_PWD';
flush privileges;
QUERY_INPUT
echo ".";
echo "***************************************************************";
echo "* Opening firewall ports for IP telephony on default zone ... *";
echo "***************************************************************";
sleep 3;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=5060/udp --permanent;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=5060/tcp --permanent;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=5061/udp --permanent;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=5061/tcp --permanent;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=4569/udp --permanent;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=5038/tcp --permanent;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=10000-20000/udp --permanent;
firewall-cmd --reload;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --list-all;
echo ".";
echo "**************************************************************";
echo "* Getting HellermannTyton's Asterisk configuration files ... *";
echo "**************************************************************";
sleep 3;
cd ~;
rm -rf /data/asterisk-install/configuration-files;
mkdir -p /data/asterisk-install/configuration-files;
cd /data/asterisk-install/configuration-files;
cp -f /etc/asterisk/asterisk.conf /data/asterisk-install/configuration-files/asterisk-original.conf;
cp -f /etc/asterisk/extensions.conf /data/asterisk-install/configuration-files/extensions-original.conf;
cp -f /etc/asterisk/modules.conf /data/asterisk-install/configuration-files/modules-original.conf;
cp -f /etc/asterisk/pjsip.conf /data/asterisk-install/configuration-files/pjsip-original.conf;
cd /etc/asterisk;
rm -f /etc/asterisk/asterisk.conf;
rm -f /etc/asterisk/extensions.conf;
rm -f /etc/asterisk/modules.conf;
rm -f /etc/asterisk/pjsip.conf;
wget -O asterisk.conf https://www.dropbox.com/s/r7k0wixm7fezw1s/asterisk.conf.txt?dl=0;
wget -O extensions.conf https://www.dropbox.com/s/adjiili64sc4yyp/extensions.conf.txt?dl=0;
wget -O modules.conf https://www.dropbox.com/s/ze8pv5yqeluh4pv/modules.conf.txt?dl=0;
wget -O pjsip.conf https://www.dropbox.com/s/q6xfmnd1ceg13tc/pjsip.conf.txt?dl=0;
dos2unix asterisk.conf;
dos2unix extensions.conf;
dos2unix modules.conf;
dos2unix pjsip.conf;
echo ".";
echo "***************************"
echo "* Re-enabling selinux ... *"
echo "***************************"
sleep 3
sed -i 's/\(^SELINUX=\).*/\SELINUX=enforcing/' /etc/selinux/config
echo "**********************************************************"
echo "*      >>> SELINUX ENABLED IN CONFIGURATION FILE <<<     *"
echo "* Please reboot your computer to start in enforcing mode *"
echo "**********************************************************"
echo "."
echo "*************************";
echo "* Starting Asterisk ... *";
echo "*************************";
sleep 3;
cd;
systemctl daemon-reload;
systemctl restart asterisk;
systemctl status asterisk;
echo "Finish time: "`date` >> ~/asterisk-install-time;
sleep 3;
stty sane;
clear;
asterisk -rv;
