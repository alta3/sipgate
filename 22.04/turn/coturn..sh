`sudo apt install -y coturn`

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
