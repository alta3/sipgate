# sipgate

sipgate requires the following services:

- A sipgrate server, with a single interface
- A valid domain `sip.alta3.com` FQDN
- A valid certificate
- A js SIP client
- NGINX to serve the js SIP client
- Kamailio Secure Web socket to SIP gateway (WSS to SIP)
- A turn server for NAT traversal
- A SIP target to call. `asterisk server`

### FQDN

1. area 53 dns is resolving sip.alta3.com to 71.251.147.236

0. pfsense is forwarding 5060 and RTP ports to the sipgrate server


### Install certbot
------
1. Use lets-ecrypt to get a signed cert

    `sudo apt-get install certbot`

0. Tell certbot to create a cert.

    `sudo certbot certonly --standalone -d sip.alta3.com`

0. Admire your new key.

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/privkey.pem`

0. Admire your new chain of keys

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/fullchain.pem`
