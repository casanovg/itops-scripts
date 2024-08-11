#!/bin/sh

# HTA FilseServer Samba Setup
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

# Install samba server and utilities
# ----------------------------------
dnf -y install samba samba-winbind samba-winbind-clients pam_krb5

# Remove all samba database files, such as *.tdb and *.ldb
# --------------------------------------------------------
rm -f /var/lib/samba/lock/*
rm -f /var/lib/samba/*

# Setup primary AD controller as primary dns by editing "/etc/resolv.conf"
# ------------------------------------------------------------------------
cat /etc/resolv.conf
nslookup HTA-ADP.hellermanntyton.ar
# Reverse lookup primary AD domain controller ...
# -----------------------------------------------
nslookup 10.6.17.41
# Resolving SRV records in interactive mode ...
# ---------------------------------------------
#nslookup

# Configuring Kerberos with vi: replace only these lines under "[libdefaults]" section
# ------------------------------------------------------------------------------------
cp /etc/krb5.conf /etc/krb5-orig.conf
# vim /etc/krb5.conf
# [libdefaults]
#	default_realm = HTARGENTINA.LAN
#	dns_lookup_realm = false
#	dns_lookup_kdc = true

# Configuring the name service switch (append winbind to password and group in /etc/nsswitch.conf)
# ------------------------------------------------------------------------------------------------
# passwd:     files sss systemd winbind
# group:      files sss systemd winbind

# Local host name resolution test
# -------------------------------
# getent hosts hta-fileserver

# Find the samba version installed on the computer
# ------------------------------------------------
smbd --version

# Configure /etc/samba/smb.conf
# -----------------------------

# # See smb.conf.example for a more detailed config file or
# # read the smb.conf manpage.
# # Run 'testparm' to verify the config is correct after
# # you modified it.

# [global]
       # security = ADS
       # workgroup = HTAR
       # realm = HELLERMANNTYTON.AR

       # log file = /var/log/samba/%m.log
       # log level = 1

       # # Default ID mapping configuration for local BUILTIN accounts
       # # and groups on a domain member. The default (*) domain:
       # # - must not overlap with any domain ID mapping configuration!
       # # - must use a read-write-enabled back end, such as tdb.
       # # - Adding just this is not enough
       # # - You must set a DOMAIN backend configuration, see below
       # idmap config * : backend = tdb
       # #idmap config * : range = 3000-7999
       # idmap config * : range = 10000-2000000000

       # username map = /usr/local/samba/etc/user.map

       # vfs objects = acl_xattr
       # map acl inherit = yes
       # store dos attributes = yes

       # bind interfaces only = yes
       # interfaces = lo enp0s3


# [HTA-Files]
       # path = /data/netfiles-disk/hta-files
       # read only = no

# [HTA-Users]
       # path = /data/netfiles-disk/hta-users
       # read only = no

# [HTA-Root$]
       # path = /data/netfiles-disk
       # read only = no


# Mapping the Domain Administrator Account to the Local root User
# ---------------------------------------------------------------
#vim /usr/local/samba/etc/user.map
#!root = HTAR\Administrator

# Solve the "Unable to initialize messaging context!" problem
# -----------------------------------------------------------
#mkdir /var/lib/samba/private
#smbclient -L HTA-ADP.hellermanntyton.ar

# Get kerberos ticket for the member server
#kinit Administrator

# Enable Samba firewall port
# --------------------------
#firewall-cmd --permanent --add-service=samba
#firewall-cmd --reload
