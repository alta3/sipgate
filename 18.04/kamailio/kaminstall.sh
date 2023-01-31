#!/bin/bash 

# Source files are in: ~/siplabcreater/kamailio
# Work directory is:   ~/github/kamailio

# Install the dependencies
sudo apt install gcc g++ flex bison libmysqlclient-dev make libcurl4-openssl-dev libssl-dev libxml2-dev libpcre3-dev libunistring-dev mysql-server libsctp-dev

# Secure the mysql installation (this is a mysql parameter)
sudo mysql_secure_installation

# Create directory
mkdir -p ~/github

# CD into new directory
cd ~/github

# Clone the kamailio REPO
sudo git clone --depth 1 --no-single-branch https://github.com/kamailio/kamailio kamailio

# cd into the new git repo
cd kamailio/

# drop back to 5.1
sudo git checkout -b 5.1 origin/5.1

# Generate build config files
make cfg

# Edit the modules.lst file and include the extra modules listed below on line 10
# vim /home/ubuntu/github/kamailio/src/modules.lst 
cp  ~/siplabcreater/kamailio/modules.lst ~/github/kamailio/src/modules.lst

# Make cfg
make include_modules="db_mysql dialplan presence regex websocket rtpengine tls sctp" cfg

# Compile
make all

# Install
sudo make install

## Edit the kamctlrc file changing user passwords and adding DBENGINE=MYSQL
# sudo vim /usr/local/etc/kamailio/kamctlrc
sudo cp ~/siplabcreater/kamailio/kamctlrc  /usr/local/etc/kamailio/kamctlrc

# copy kamailio.cfg to the proper directory with edits
### edit line 123(ish) in this example assuming the password is "kam12345"
#   #!define DBURL "mysql://kamailio:kam12345@localhost/kamailio"
# in the #! section, enable the WITH_MYSQL compiler directives
# =============================================
# #!define WITH_MYSQL
# #!define WITH_AUTH
# #!define WITH_USRLOCDB
# =============================================
sudo cp  ~/siplabcreater/kamailio/kamailio.cfg  /usr/local/etc/kamailio/kamailio.cfg

# Create the database
sudo /usr/local/sbin/kamdbctl create


# Edit kamailio.cfg file {{THIS NEEDS A TEMPLATE}}
sudo vim /usr/local/etc/kamailio/kamailio.cfg

# The init script is already to go, but check to be sure it is pointing at kamailio executables and config files
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin
DAEMON=/usr/local/sbin/kamailio
CFGFILE=/user/local/etc/kamailio/kamailio.cfg

# Copy kamailio.init to /etc/init.d
sudo cp ~/siplabcreater/kamailio/kamailio.init   /etc/init.d/kamailio

# Don't forget to set the permissions:
sudo chmod 755 /etc/init.d/kamailio

# Copy (and rename) kamailio.defaults file to /etc/defaults/kamailio
sudo cp ~/siplabcreater/kamailio/kamailio.default   /etc/default/kamailio

# Edit defaults file to run RUN_KAMAILIO=yes (simply uncomment)
sudo vim /etc/default/kamailio

# Create the directory for pid file
sudo mkdir -p /var/run/kamailio

# Add kamailio user
sudo adduser --quiet --system --group --disabled-password --shell /bin/false --gecos "Kamailio" --home /var/run/kamailio kamailio

# chown the file
sudo chown kamailio:kamailio /var/run/kamailio


