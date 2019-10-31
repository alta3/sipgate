#  Install kamailio on ubuntu 18.04

**The password *kam12345* is used as an example. OK to try it for testing, but NO WAY do you let that password make it to production!**

Source files are in: ~/sipgate/kamailio  
Work directory is:   ~/github/kamailio

Begin
------

1. Install the dependencies

    `sudo apt install -y gcc g++ flex bison libmysqlclient-dev make libcurl4-openssl-dev libssl-dev libxml2-dev libpcre3-dev libunistring-dev mysql-server libsctp-dev`

0. Secure the mysql installation (this is a mysql parameter)

    `sudo mysql_secure_installation  --user=root --password=kam12345  --use-default`

0. Create directory

    `mkdir -p ~/github`

0. CD into new directory

    `cd ~/github`

0. Clone the kamailio REPO

    `git clone --depth 1 --no-single-branch https://github.com/kamailio/kamailio kamailio`

0. cd into the new git repo

    `cd kamailio`

0. drop back to 5.1

    `git checkout -b 5.1 origin/5.1` 

0. Generate build config files

    `make cfg`

0. Optionally, edit the modules.lst file and include the extra modules listed below on line 10. Should be good to go as it is.  

    `vim ~/sipgate/kamailio/modules.lst`

0. Copy the file into the workspace

    `cp  ~/sipgate/kamailio/modules.lst ~/github/kamailio/src/modules.lst`

0. Make cfg

    `make include_modules="db_mysql dialplan presence regex websocket rtpengine tls sctp" cfg`

0. Compile kamailio

    `make all`

0. Install kamailio

    `sudo make install` 

0.  Edit the kamctlrc file changing user passwords and adding DBENGINE=MYSQL Should already be done.

    `vim ~/sipgate/kamailio/kamctlrc`  

        SIP_DOMAIN=sip.alta3.com
        DBENGINE=MYSQL
        #DBNAME=kamailio
        DBRWUSER="kamailio"
        DBRWPW="kam12345"
        DBROUSER="kamailioro"
        DBROPW="kam12345"
        DBROOTUSER="root"
        DBROOTPW="kam12345"

0. Copy the kamctlrc file to the workspace.

    `sudo cp ~/sipgate/kamailio/kamctlrc  /usr/local/etc/kamailio/kamctlrc`

    > If the above step fails, most likely do to password policy set too high, make these changes....  
      `mysql>` `SET GLOBAL validate_password_policy=LOW;`  
      `mysql>` `ALTER USER 'root'@'localhost' IDENTIFIED BY 'kam12345';`  
      `mysql>` `SHOW DATABASES;`  
      `mysql>` `DROP DATABASE kamailio`  

0. copy [kamailio.cfg](https://raw.githubusercontent.com/alta3/sipgate/master/kamailio/kamailio.cfg?token=ADITSNB6UVKCBCKN52WXEL25YMAL6) to the proper directory with edits. 

    **TODO: mysql database password NOT secure!**

    `sudo cp  ~/sipgate/kamailio/kamailio.cfg  /usr/local/etc/kamailio/kamailio.cfg`

0. Create the database. Answer `y` to all questions. It is possible to edit the kamdbctl script and hard-code the answers, but not now.

    `sudo /usr/local/sbin/kamdbctl create`

        FYI: mysql: [Warning]'s have been removed for clarity...
        INFO: test server charset
        INFO: creating database kamailio ...
        INFO: granting privileges to database kamailio ...
        INFO: creating standard tables into kamailio ...
        INFO: Core Kamailio tables succesfully created.
        Install presence related tables? (y/n): y     <-- answer "y"
        INFO: creating presence tables into kamailio ...
        INFO: Presence tables succesfully created.
        Install tables for imc cpl siptrace domainpolicy carrierroute
                        drouting userblacklist htable purple uac pipelimit mtree sca mohqueue
                        rtpproxy rtpengine? (y/n): y  <-- answer "y"
        INFO: creating extra tables into kamailio ...
        INFO: Extra tables succesfully created.
        Install tables for uid_auth_db uid_avp_db uid_domain uid_gflags
                        uid_uri_db? (y/n): y          <-- answer "y"
        INFO: creating uid tables into kamailio ...
        INFO: UID tables succesfully created.


    > If this fails, try this..
    
        how databases;
        drop database kamailio;
        ALTER USER 'root'@'localhost' IDENTIFIED BY 'kam12345';
        quit
        Now try again....


0. Edit kamailio.cfg file {{IP ADDR, etc}}

    `sudo vim /usr/local/etc/kamailio/kamailio.cfg`

0. The init script is already to go, but check to be sure it is pointing at kamailio executables and config files

        PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin
        DAEMON=/usr/local/sbin/kamailio
        CFGFILE=/usr/local/etc/kamailio/kamailio.cfg

0. Copy kamailio.init to /etc/init.d

    `sudo cp ~/sipgate/kamailio/kamailio.init   /etc/init.d/kamailio`

0. Don't forget to set the permissions:

    `sudo chmod 755 /etc/init.d/kamailio`

0. Copy (and rename) kamailio.defaults file to /etc/defaults/kamailio

    `sudo cp ~/sipgate/kamailio/kamailio.default   /etc/default/kamailio`

0. Edit defaults file to run RUN_KAMAILIO=yes (simply uncomment)

    `sudo vim /etc/default/kamailio`

0. Create the directory for pid file

    `sudo mkdir -p /var/run/kamailio`

0. Add kamailio user, ignore the complaint, it is fixed in the next line.

    `sudo adduser --quiet --system --group --disabled-password --shell /bin/false --gecos "Kamailio" --home /var/run/kamailio kamailio`

0. fix the "chown" issue. 

    `sudo chown kamailio:kamailio /var/run/kamailio`

