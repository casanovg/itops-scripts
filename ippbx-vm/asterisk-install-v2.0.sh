1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
162
163
164
165
166
167
168
169
170
171
172
173
174
175
176
177
178
179
180
181
182
183
184
185
186
187
188
189
190
191
192
193
194
195
196
197
198
199
200
201
202
203
204
205
206
207
208
209
210
211
212
213
214
215
216
217
218
219
220
221
222
223
224
225
226
227
228
229
230
231
232
233
234
235
236
237
238
239
240
241
242
243
244
245
246
247
248
249
250
251
252
253
254
255
256
257
258
259
260
261
262
263
264
265
266
267
268
269
270
271
272
273
274
275
276
277
278
279
280
281
282
283
284
285
286
287
288
289
290
291
292
293
294
295
296
297
298
299
300
301
302
303
304
305
306
307
308
309
310
311
312
313
314
315
316
317
318
319
320
321
322
323
324
325
326
327
328
329
330
331
332
333
334
335
336
337
338
339
340
341
342
343
344
345
346
347
348
349
350
351
352
353
354
355
356
357
358
359
360
361
362
363
364
365
366
367
368
369
370
371
372
373
374
375
376
377
378
379
380
381
382
383
384
385
386
387
388
389
390
391
392
393
394
395
396
397
398
399
400
401
402
403
404
405
406
407
408
409
410
411
412
413
414
415
416
417
418
419
420
421
422
423
424
425
426
427
428
429
430
431
432
433
434
435
436
437
438
439
440
441
442
443
444
445
446
447
448
449
450
451
452
453
454
455
456
457
458
459
460
461
462
clear;
echo "#######################################################";
echo "# Asterisk 13 LTS Fedora 23 Installation Script       #";
echo "# =============================================       #";
echo "# v2.0: 2016-05-15  >>> Includes FreePBX 13 <<<       #";
echo "# ---------------------------------------------       #";
echo "# Gustavo Casanova (gcasanova@hellermanntyton.com.ar) #";
echo "#######################################################";
echo "";
echo "Start time: "`date` >> ~/asterisk-install-time;
#########################
# Environment Variables #
#########################
ASTERISK_UNIX_USR="asterisk";
ASTERISK_MYSQL_USR="asterisk";
ASTERISK_MYSQL_PWD="asterisk";
ASTERISK_MYSQL_MAINDB="asterisk";
ASTERISK_MYSQL_CDRDB="cdrdb";
MYSQL_ROOT_PASSWORD="PrincessLeia77";
INSTALL_FILES_DIR="/data/asterisk-install";
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
mkdir -p $INSTALL_FILES_DIR;      
echo ".";
cd $INSTALL_FILES_DIR;
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
tar -zxvf $INSTALL_FILES_DIR/dahdi-linux-complete-current.tar.gz;
tar -zxvf $INSTALL_FILES_DIR/libpri-current.tar.gz;
tar -zxvf $INSTALL_FILES_DIR/asterisk-13-current.tar.gz;
# rm -f $INSTALL_FILES_DIR/dahdi-linux-complete-current.tar.gz;
# rm -f $INSTALL_FILES_DIR/libpri-*.tar.gz;
# rm -f $INSTALL_FILES_DIR/asterisk-13-current.tar.gz;
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
dnf -y --best --allowerasing install kernel-devel;
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
dnf -y install mysql-connector-odbc;
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
dnf -y install postfix;
dnf -y install postgresql-devel;
dnf -y install psmisc;
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
dnf -y install system-switch-mail;
dnf -y install tftp-server;
dnf -y install unixODBC;
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
send \"n\r\"
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
echo "******************************";
echo "* Starting Apache web server *";
echo "******************************";
systemctl enable httpd.service;
systemctl start httpd.service;
echo ".";
#echo "****************************************";
#echo "* Compiling and installing iksemel ... *";
#echo "****************************************";
#cd $INSTALL_FILES_DIR;
#wget https://iksemel.googlecode.com/files/iksemel-1.4*.tar.gz;
#tar xf iksemel-*.tar.gz;
#rm -f iksemel-1.4.tar.gz;
#cd iksemel-*;
#./configure;
#make;
#make install;
#echo ".";
echo "***********************************************************************";
echo "* Compiling and installing Jansson library for JSON data handling ... *";
echo "***********************************************************************";
sleep 3;
# dnf -y jansson;
cd $INSTALL_FILES_DIR;
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
echo "*********************************************************************";
echo "* Dowloading and installing kernel-devel-4.4.6 to compile DAHDI ... *";
echo "*********************************************************************";
sleep 3;
cd $INSTALL_FILES_DIR
wget https://kojipkgs.fedoraproject.org/packages/kernel/4.4.6/300.fc23/x86_64/kernel-devel-4.4.6-300.fc23.x86_64.rpm
dnf -y install ./kernel-devel-4.4.6-300.fc23.x86_64.rpm;
echo ".";
echo "**********************************************";
echo "* Compiling and installing DAHDI library ... *";
echo "**********************************************";
sleep 3;
cd $INSTALL_FILES_DIR/dahdi-linux-complete-*;
make all;
make install;
make config;
echo ".";
echo "***********************************************";
echo "* Compiling and installing LibPRI library ... *";
echo "***********************************************";
sleep 3;
cd $INSTALL_FILES_DIR/libpri-*;
make;
make install;
echo ".";
echo "**********************************************";
echo "* Compiling and installing PJSIP library ... *";
echo "**********************************************";
sleep 3;
cd $INSTALL_FILES_DIR;
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
cd $INSTALL_FILES_DIR/asterisk-13.*;
$INSTALL_FILES_DIR/asterisk-13.*/contrib/scripts/get_mp3_source.sh;
echo ".";
echo "***************************************";
echo "* Configuring Asterisk 13 modules ... *";
echo "***************************************";
echo "";
sleep 5;                           
cd $INSTALL_FILES_DIR/asterisk-13.*;
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
  cd $INSTALL_FILES_DIR/asterisk-13.*
  make menuselect.makeopts
  mv -f ~/Asterisk-Modules-Menuselect $INSTALL_FILES_DIR/asterisk-13.*/
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
echo "* Compiling and installing Asterisk 13 ... *";
echo "********************************************";
sleep 3;
cd $INSTALL_FILES_DIR/asterisk-13.*;
make;
make install;
make config;
ldconfig;
chkconfig asterisk off;
echo ".";
echo "*****************************************";
echo "* Installing Open Source G729 Codec ... *";
echo "*****************************************";
cd /usr/lib64/asterisk/modules;
wget -O codec_g729.so https://www.dropbox.com/s/wg60pznkyjj0krf/codec_g729-ast130-gcc4-glibc-x86_64-core2-sse4.so?dl=0;
chmod 755 ./codec_g729.so;
echo ".";
echo "***************************************";
echo "* Adding Asterisk service account ... *";
echo "***************************************";
sleep 3;
useradd $ASTERISK_UNIX_USR -m -c "Asterisk User";
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /var/run/asterisk;
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /etc/asterisk;
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /var/{lib,log,spool}/asterisk;
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /usr/lib64/asterisk;
chown -R $ASTERISK_UNIX_USR.$ASTERISK_UNIX_USR /var/www/;
echo ".";
echo "************************************";
echo "* Configuring Asterisk service ... *";
echo "************************************";
sleep 3;
cd $INSTALL_FILES_DIR/asterisk-13.*;
cp -f ./contrib/init.d/rc.redhat.asterisk /etc/init.d/asterisk;
sed -i 's/\(^AST_SBIN=\).*/\AST_SBIN=\/usr\/sbin/' /etc/init.d/asterisk
chmod 755 /etc/init.d/asterisk;
echo ".";
echo "*****************************************************";
echo "* Setting-up Asterisk database on MariaDB RDBMS ... *";
echo "*****************************************************";
sleep 3;
#mysql -uroot -p$MYSQL_ROOT_PASSWORD <<QUERY_INPUT
mysql -uroot <<QUERY_INPUT
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
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --add-port=80/tcp --permanent;
firewall-cmd --reload;
firewall-cmd --zone=$(firewall-cmd --get-default-zone) --list-all;
echo ".";
echo "******************************************************";
echo "* Installing Fail2Ban intrusion detection system ... *";
echo "******************************************************";
sleep 3;
dnf -y install fail2ban;
echo ".";
echo "************************************";
echo "* Modifying Apache for FreePBX ... *";
echo "************************************";
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini;
sed -i 's/^\(User\|Group\).*/\1 '$ASTERISK_UNIX_USR/ /etc/httpd/conf/httpd.conf;
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf;
systemctl restart httpd.service;
echo ".";
# echo "******************************************";
# echo "* Downloading and installing FreePBX ... *";
# echo "******************************************";
cd $INSTALL_FILES_DIR;
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-13.0-latest.tgz;
tar xfz freepbx-13.0-latest.tgz;
rm -f freepbx-13.0-latest.tgz;
cd freepbx;
./start_asterisk start;
./install -n;
echo ".";
echo "***********************************";
echo "* Configuring FreePBX service ... *";
echo "***********************************";
sleep 3;
cd $INSTALL_FILES_DIR/freepbx/amp_conf/etc/init.d;
cp -f ./freepbx.init /etc/init.d/freepbx;
chmod 755 /etc/init.d/freepbx;
chkconfig --add freepbx;
chkconfig --level 3 freepbx on;
echo ".";
#echo "***************************";
#echo "* Re-enabling selinux ... *";
#echo "***************************";
#sleep 3;
#sed -i 's/\(^SELINUX=\).*/\SELINUX=enforcing/' /etc/selinux/config;
#echo "**********************************************************";
#echo "*      >>> SELINUX ENABLED IN CONFIGURATION FILE <<<     *";
#echo "* Please reboot your computer to start in enforcing mode *";
#echo "**********************************************************";
#echo ".";
echo "***********************************";
echo "* Starting Asterisk & FreePBX ... *";
echo "***********************************";
sleep 3;
cd;
echo "Finish time: "`date` >> ~/asterisk-install-time;
sleep 3;
stty sane;
clear;
fwconsole restart;
fwconsole motd;
