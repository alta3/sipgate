# Install WEB-RTC using Kamailion on ubuntu 18.04

Refer to [WEBRTC-to-SIP](https://github.com/havfo/WEBRTC-to-SIP/blob/master/README.md) for the source document of steps that mostly work. Corrections listed here.


### Parts of the WEB-RTC repo are usable (for now)

1. Clone the webrtc repo

    `git clone git@github.com:havfo/WEBRTC-to-SIP.git`

0. cd into the newly cloned repo

    `cd WEBRTC-to-SIP/`

0. Replace the *"6x-6x"* pattern in all files with your server's IPv6 address.

    `find . -type f -print0 | xargs -0 sed -i 's/XXXXXX-XXXXXX/fe80::20c:29ff:fed9:ba61/g'`

0. Replace the *"5x-5x"* pattern in all files with your server's IP address

    `find . -type f -print0 | xargs -0 sed -i 's/XXXXX-XXXXX/10.16.1.198/g'`

0. Replace the *"4x-4x"* in all files with your server's domain name.

    `find . -type f -print0 | xargs -0 sed -i 's/XXXX-XXXX/sip.alta3.com/g'`

0. cd back to home

    `cd`

### Install certbot
------
1. Use lets-ecrypt to get a signed cert

    `sudo apt-get install -y certbot`

0. Tell certbot to create a cert.

    `sudo certbot certonly --standalone -d sip.alta3.com`

0. Admire your new key.

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/privkey.pem`

0. Admire your new chain of keys

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/fullchain.pem`



### Install rtpengine
-----
1. The ubuntu ntp servers are too bogged down to respond to NTP. Point systemd-timesyncd to google NTP servers.

    `sudo vim /etc/systemd/timesyncd.conf`

       # CONFIG /etc/systemd/timesyncd.conf
       [Time]
       #NTP=
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

0. Stop rtpengine as follows:

    `sudo pkill rtpengine` 

0. Start rtpengine as follows:

    `sudo rtpengine` 
