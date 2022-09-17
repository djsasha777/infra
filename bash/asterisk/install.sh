#!/bin/sh

#Prerequisites
sudo apt update && sudo apt -y upgrade
sudo apt-get install git curl wget \
libnewt-dev libssl-dev libncurses5-dev \
subversion libsqlite3-dev build-essential \
libjansson-dev libxml2-dev  uuid-dev

#Download the latest release of Asterisk 15 to your local system for installation.
sudo su -
cd /usr/src/
curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-19-current.tar.gz

tar xvf asterisk-19-current.tar.gz
cd asterisk-19*/
#Run the following command to download the mp3 decoder library into the source tree.
sudo contrib/scripts/get_mp3_source.sh

#Ensure all dependencies are resolved:
sudo contrib/scripts/install_prereq install

#Build and Install Asterisk from source
./configure

#Setup menu options by running the following command: Use arrow keys to navigate, and Enter key to select. On Add-ons select chan_ooh323 and format_mp3. 2nd On Core Sound Packages, select the formats of Audio packets. For Music On Hold, select the following minimal modules. On Extra Sound Packages select first 4.
make menuselect

#You can change other configurations you see fit. When done, save and exit then install Asterisk with selected modules:
make
make install
make samples
make config
ldconfig

#Create separate user and group to run asterisk services, and assign correct permissions:
sudo groupadd asterisk
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
sudo usermod -aG audio,dialout asterisk
sudo chown -R asterisk.asterisk /etc/asterisk
sudo chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
sudo chown -R asterisk.asterisk /usr/lib/asterisk

#Set Asterisk default user to asterisk:
sudo nano /etc/default/asterisk
AST_USER="asterisk"
AST_GROUP="asterisk"

sudo nano /etc/asterisk/asterisk.conf
runuser = asterisk ; The user to run as.
rungroup = asterisk ; The group to run as.

#Restart asterisk service after making the changes:
sudo systemctl restart asterisk
sudo systemctl enable asterisk

#Troubleshooting

#Problem: *reference: https://www.clearhat.org/2019/04/12/a-fix-for-apt-install-asterisk-on-ubuntu-18-04/
#radcli: rc_read_config: rc_read_config: can't open /etc/radiusclient-ng/radiusclient.conf: No such file or directory
#Fix:
sed -i 's";\[radius\]"\[radius\]"g' /etc/asterisk/cdr.conf
sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cdr.conf
sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' /etc/asterisk/cel.conf

#Test to see if you can connect to Asterisk CLI:
sudo asterisk -rvv


#Install FreePBX 15 on Ubuntu


#Or Install Apache, mariadb and php7.3
sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
apt-get install apache2 mariadb-server libapache2-mod-php7.4 php7.4-cgi php7.4-common php7.4-curl php7.4-mbstring php7.4-gd php7.4-mysql php7.4-bcmath php7.4-zip php7.4-xml php7.4-imap php7.4-json php7.4-snmp

#Then set options below:
sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf_orig
sudo sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf
sudo sed -i 's/AllowOverride/'/etc/apache2/apache2.conf

#Change PHP maximum file upload size: For Ubuntu 20.04:
sudo sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/7.4/cli/php.ini

#Download and Install FreePBX
cd /usr/src
sudo wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-16.0-latest.tgz
sudo tar xfz freepbx-16.0-latest.tgz
sudo rm -f freepbx-16.0-latest.tgz
cd freepbx
sudo ./start_asterisk start
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo ./install -n

#Enable Apache Rewrite engine and restart apache2.
sudo a2enmod rewrite
sudo systemctl restart apache2

#If you have an active ufw firewall, open http ports and ports 5060,5061
sudo ufw enable
sudo ufw allow 5060
sudo ufw allow 5061

#That’s it!. You have a ready Asterisk 15 with FreePBX 15 on your Ubuntu server. Open up your web browser and connect to the ip_address_or_hostname/admin of your new FreePBX server.
#Visit: http://localhost/admin

#configure and restart asterisk
# cp sip.cong /etc/asterisk/sip.conf
# cp extensions.conf /etc/asterisk/extensions.conf
# systemctl restart asterisk