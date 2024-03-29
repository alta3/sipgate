# sipgate

![sipgrate](https://github.com/alta3/sipgate/blob/main/18.04/images/sipgate2.png)

**sipgate requires the following services:**

1. A sipgate server, with a single interface in the alt3 services subnet `10.1.16.0/24`
2. A valid domain `sip.alta3.com`
3. NTP config update
4. A SSL certificate `lets-encrypt`
5. A js SIP client
6. NGINX to serve the js SIP client
7. Kamailio Secure Web socket to SIP gateway `WSS to SIP`
8. siremix kamailio DB manager
9. NAT Traversal RTP proxy `rtpengine`
10. A turn server for NAT traversal  `coturn`
11. A SIP target to call. `asterisk server`


----
### 1 - sipgate server
hostname: `sipgate`  
subnet:  `10.1.16.0/24`  
vlan: `1601`  
ip addr: `sipgate.localdomain`  
cores: `4`  
mem: `8G`  
storage `100G`  

1. Most likely, you are on a new VM nothing configured, so do the drill to clone the sipgate repo...

    `cd ~/.ssh`
    
    `ssh-keygen`
    
    copy `id_rsa.pub` the public key to github    

    `git clone git@github.com:alta3/sipgate.git`

----
### 2 - SIP Domain
1. area 53 dns is resolving `sip.alta3.com` to `71.251.147.236`

0. The cloud pfsense is forwarding 5060 and RTP ports to the sipgate server

----
### 3 - NTP
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

----
### 4 - SSL certificate

1. Use lets-ecrypt to get a signed cert

    `sudo apt-get -y install certbot`

0. Tell certbot to create a cert.

    `sudo certbot certonly --standalone -d sip.alta3.com`

0. Admire your new key.

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/privkey.pem`

0. Admire your new chain of keys

    `sudo cat /etc/letsencrypt/live/sip.alta3.com/fullchain.pem`

----
### 5 - JS Client

1. clone the repo that inspired sipgate ---> [WEB-RTC repo](https://github.com/havfo/WEBRTC-to-SIP)

    `git clone https://github.com/havfo/WEBRTC-to-SIP.git`

0. cd into the repo

    `cd WEBRTC-to-SIP`

0. mkdir /var/www/html/

    `sudo mkdir -p /var/www/html/`
    
0. Install sip js client. [This client](https://github.com/havfo/SipCaller) is what you are installing

    `sudo cp -r client/* /var/www/html/`

0. vim the js config file

    `sudo vim /var/www/html/config.js`

       var iceServers = [
               {
                  urls       : 'turn:sip.alta3.com:443?transport=tcp',
                  username   : 'websip',
                  credential : 'websip'
               },
               {
                  urls       : 'turns:sip.alta3.com:80?transport=tcp',
                  username   : 'websip',
                  credential : 'websip'
               }
       ];


----
### 6 - NGINX install from source  
> See [README.md](https://github.com/alta3/sipgate/tree/master/nginx) for installation instructions

----
### 7 - KAMAILIO install from source  
> See [README.md](https://github.com/alta3/sipgate/blob/master/kamailio/README.md) for installation instructions

### 8 - Install ngcp-rtpengine  
> See [README.md](https://github.com/alta3/sipgate/blob/master/rtpengine/README.md) for installation instructions

----
### 9 - coturn TURN Server 
>[Turn Server](https://github.com/coturn/coturn)

0. Apt install coturn

    `sudo apt-get install -y coturn`

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

    `sudo service coturn restart`  

### TESTING

1. Add some users to kamailio

    `sudo kamctl add 2251 seansecret`  
    `sudo kamctl add 2250 tracysecret`  
    `sudo kamctl add 2228 hilarysecret`  
    `sudo kamctl add 2222 stusecret`  
    
    `sudo service kamailio restart`  
    
0. Login at https://sip.alta3.com (sean example)

        Display name: Sean
        SIP URI: 2251@sip.alta3.com
        Password: seansecret
        Outbound Proxy: wss://sip.alta3.com/ws

0. At the CLI, list the provisioned users: 

    `kamctl db show subscriber`
    
        +----+----------+---------------+--------------+----------------------------------+----------------------------------+---------------+------+
        | id | username | domain        | password     | ha1                              | ha1b                             | email_address | rpid |
        +----+----------+---------------+--------------+----------------------------------+----------------------------------+---------------+------+
        |  1 | 2251     | sip.alta3.com | seansecret   | b5cb0b9d534921233da1f9fd1ad4a9f0 | f4d6f82bb84bd5575b0a96150cc74c17 | NULL          | NULL |
        |  2 | 2250     | sip.alta3.com | tracysecret  | 8c6d557582f939847429a2bd3db8c247 | 8eb16e448e76fbd73bf268a88db28757 | NULL          | NULL |
        |  3 | 2228     | sip.alta3.com | hilarysecret | a55607a7de87ef3ebd94a2de0c646677 | e579cc13c4351d7d65c950af6c4ee70d | NULL          | NULL |
        |  4 | 2222     | sip.alta3.com | stusecret    | e3c1f07a1a1a580cb31e8e1182dda594 | 8c050b96e1a27ccb915e4bad71fc678c | NULL          | NULL |
        |  5 | 2230     | sip.alta3.com | bjsecret     | 601bfe94a62304698b25baeab3dab499 | 2befe1be8cafc01319881ec7b897f4dd | NULL          | NULL |
        |  6 | 2004     | sip.alta3.com | samsecret    | 8e8aa45725f1467320459a19abb68efe | 119ab25bc743f9d8965ab8903e3d5473 | NULL          | NULL |
        +----+----------+---------------+--------------+----------------------------------+----------------------------------+---------------+------+
