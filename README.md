# sipgate

**sipgate requires the following services:**

1. A sipgate server, with a single interface in the alt3 services subnet `10.1.16.0/24`
2. A valid domain `sip.alta3.com`
3. A valid certificate `lets-encrypt`
4. A js SIP client
5. NGINX to serve the js SIP client
6. Kamailio Secure Web socket to SIP gateway `WSS to SIP`
7. A turn server for NAT traversal
8. A SIP target to call. `asterisk server`


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
### 3 - TLS cert
1. Use lets-ecrypt to get a signed cert

    `sudo apt-get install certbot`

0. Tell certbot to create a cert.

    `sudo certbot certonly --standalone -d sip.alta3.com`

0. Admire your new key.

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/privkey.pem`

0. Admire your new chain of keys

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/fullchain.pem`

### 4 - JS Client

1. The [WEB-RTC repo](https://github.com/havfo/WEBRTC-to-SIP) says that [this client](https://github.com/havfo/SipCaller) is supposed to work. We shall see.

0. Get a really old version of nginx (why)

    `echo 'deb http://nginx.org/packages/mainline/debian/ stretch nginx' > /etc/apt/sources.list.d/nginx.list`

0. get the key to access this nginx version curl (why)

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
