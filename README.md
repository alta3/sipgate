# sipgate

**sipgate requires the following services:**

- A sipgate server, with a single interface in the alt3 services subnet `10.1.16.0/24`
- A valid domain `sip.alta3.com`
- A valid certificate `lets-encrypt`
- A js SIP client
- NGINX to serve the js SIP client
- Kamailio Secure Web socket to SIP gateway `WSS to SIP`
- A turn server for NAT traversal
- A SIP target to call. `asterisk server`


----
### sipgate server
hostname: `sipgate`  
subnet:  `10.1.16.0/24`  
vlan: `1601`  
ip addr: `sipgate.localdomain`  
cores: `4`  
mem: `8G`  
storage `100G`  

----
### FQDN
1. area 53 dns is resolving sip.alta3.com to 71.251.147.236

0. pfsense is forwarding 5060 and RTP ports to the sipgate server

----
### Install certbot
1. Use lets-ecrypt to get a signed cert

    `sudo apt-get install certbot`

0. Tell certbot to create a cert.

    `sudo certbot certonly --standalone -d sip.alta3.com`

0. Admire your new key.

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/privkey.pem`

0. Admire your new chain of keys

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/fullchain.pem`
