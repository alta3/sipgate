# sipgate

**sipgate requires the following services:**

1. A sipgate server, with a single interface in the alt3 services subnet `10.1.16.0/24`
2. A valid domain `sip.alta3.com`
3. A SSL certificate `lets-encrypt`
4. A js SIP client
5. NGINX to serve the js SIP client
6. Kamailio Secure Web socket to SIP gateway `WSS to SIP`
7. siremix kamailio DB manager
8. NAT Traversal RTP proxy `rtpengine`
9. A turn server for NAT traversal  `coturn`
10. A SIP target to call. `asterisk server`


----
### 1 - sipgate server
hostname: `sipgate`  
subnet:  `10.1.16.0/24`  
vlan: `1601`  
ip addr: `sipgate.localdomain`  
cores: `4`  
mem: `8G`  
storage `100G`  

----
### 2 - SIP Domain
1. area 53 dns is resolving `sip.alta3.com` to `71.251.147.236`

0. The cloud pfsense is forwarding 5060 and RTP ports to the sipgate server

----
### 3 - SSL certificate

1. Use lets-ecrypt to get a signed cert

    `sudo apt-get -y install certbot`

0. Tell certbot to create a cert.

    `sudo certbot certonly --standalone -d sip.alta3.com`

0. Admire your new key.

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/privkey.pem`

0. Admire your new chain of keys

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/fullchain.pem`

----
### 4 - JS Client

1. The [WEB-RTC repo](https://github.com/havfo/WEBRTC-to-SIP) says that [this client](https://github.com/havfo/SipCaller) is supposed to work. We shall see.

0. Get a really old version of nginx (why?)

    `echo 'deb http://nginx.org/packages/mainline/debian/ stretch nginx' > /etc/apt/sources.list.d/nginx.list`

0. get the key to access this nginx version curl (why?)

    `curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -`

0. update

    `apt-get update`

0. Get the stretc version of nginx

    `apt-get install nginx`

0. cd into the repo

    `cd WEBRTC-to-SIP`

0. copy the nginx config file to the running directory

    `cp etc/nginx/nginx.conf /etc/nginx/`

0. Move more nginx config

    `cp etc/nginx/conf.d/default.conf /etc/nginx/conf.d/`
    
0. Install client

    `cp -r client/* /var/www/html/`
    
0. Restart nginx

    `service nginx restart`

----
### 5 - NGINX

    `sudo apt install nginx`
    
    
    
    
apt-get install nginx
cd WEBRTC-to-SIP
cp etc/nginx/nginx.conf /etc/nginx/
cp etc/nginx/conf.d/default.conf /etc/nginx/conf.d/
cp -r client/* /var/www/html/
service nginx restart

### 8 - Install ngcp-rtpengine  
> ngcp stands for next generation communication platform. It is limited to handing RTP, but can transcode, NAT RELAY, and reocrd voice. 
-----
1. The ubuntu ntp servers are too bogged down to respond to NTP. Log fills up griping ubuntu ntp servers are unresponsive, so point systemd-timesyncd to google NTP servers.

    `sudo vim /etc/systemd/timesyncd.conf`

       # CONFIG /etc/systemd/timesyncd.conf
       [Time]
       NTP=time.google.com
       FallbackNTP=time.google.com
       #RootDistanceMaxSec=5
       #PollIntervalMinSec=32
       #PollIntervalMaxSec=2048

0. Restart timesyncd

    `sudo systemctl restart systemd-timesyncd.service`

0. Create a github directory.

    `mkdir -p ~/github`
    
0. [Source info](https://nickvsnetworking.com/rtpengine-installation-configuration/) that needed tweaking to make this section work: 

0. cd into ~/github

    `cd ~/github`

0. clone rtpengine repo

    `git clone https://github.com/sipwise/rtpengine.git`

0. cd into the repo

    `cd rtpengine/`

0. Install dependancies. There are TWO critcal backports included below. You must install the exact version specified to make rtpengine work.

    `sudo apt-get install -y debhelper=12.1.1ubuntu1~ubuntu18.04.1  init-system-helpers=1.56+nmu1~ubuntu18.04.1 default-libmysqlclient-dev gperf iptables-dev libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbencode-perl libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libjson-glib-dev libdigest-crc-perl libdigest-hmac-perl libnet-interface-perl libnet-interface-perl libssl-dev libsystemd-dev libxmlrpc-core-c3-dev libcurl4-openssl-dev libevent-dev libpcap0.8-dev markdown unzip nfs-common dkms libspandsp-dev`

0. Load bash variable "$VER" to save typing....

    `VER=1.0.4`

0. G.729 codec is needed for the next step. Go get it!

    `curl https://codeload.github.com/BelledonneCommunications/bcg729/tar.gz/$VER >bcg729_$VER.orig.tar.gz`

0. untar the code

    `tar zxf bcg729_$VER.orig.tar.gz`

0. cd into the new directory ...

    `cd bcg729-$VER`

0. clone G.729 codec

    `git clone https://github.com/ossobv/bcg729-deb.git debian`

0. Create the package

    `dpkg-buildpackage -us -uc -sa`

0. cd backwards one directory

    `cd ../`

0. Create the G729 package.

    `sudo dpkg -i libbcg729-*.deb`
    
0. Check to see if all the dependancies have been met. Should be empty!

    `dpkg-checkbuilddeps`

0. Start building the packages using flags that generate unsigned deb files for local use. This takes five minutes, so find something else to do.

    `dpkg-buildpackage -us -uc -sa`  

0. cd backwards one directory

    `cd ..`

0. Edit /etc/rtpengine/rtpengine.conf. Startup FAILS without this config in place.

    `sudo vim /etc/rtpengine/rtpengine.conf`

       [rtpengine]
       table = 0
       # Use YOUR IP ADDRESS HERE not this one!
       interface = 10.16.1.195
       listen-ng = 127.0.0.1:22222
       timeout = 60
       silent-timeout = 3600
       tos = 184
       port-min = 16384
       port-max = 16485    

0. Install the package you just created ...

    `sudo dpkg -i ngcp-rtpengine-daemon_*.deb ngcp-rtpengine-iptables_*.deb ngcp-rtpengine-kernel-dkms_*.deb`

0. Check if one instance of rtpengine is running

    `sudo ps -ef | grep [r]tpengine`
    
        ubuntu   30202     1  0 21:25 pts/2    00:00:00 rtpengine   

0. **Stop rtpengine** as follows:

    `sudo sudo systemctl stop ngcp-rtpengine-daemon` 
    
0. **Start rtpengine** as follows:

    `sudo systemctl start ngcp-rtpengine-daemon`

0. **Restart rtpengine** as follows:

    `sudo systemctl restart ngcp-rtpengine-daemon` 

----
### 9 - coturn TURN Server 

0. Apt install coturn

    `apt-get install coturn`

0. Edit /etc/default/coturn

    `sudo vim /etc/default/coturn`
    
        # Uncomment it if you want to have the turnserver running as
        # an automatic system service daemon
        #
        TURNSERVER_ENABLED=1    

0. edit /etc/turnserver.conf

    `sudo vim  /etc/turnserver.conf`
    
      listening-ip=10.16.1.195
      listening-ip=fe80::20c:29ff:fead:8b42
      fingerprint
      lt-cred-mech
      user=websip:websip
      realm=sip.alta3.com
      log-file=/var/log/turn.log
      simple-log
      cert=/etc/letsencrypt/live/sip.alta3.com/fullchain.pem
      pkey=/etc/letsencrypt/live/sip.alta3.com/privkey.pem

0. Start the turn server

    `service coturn restart`  
    
