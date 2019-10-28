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
    
