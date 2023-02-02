`ssh to the turn server`

`clone the sipgate repo`

`sudo apt install -y coturn`

`edit this file /etc/default/coturn`
    
        # Uncomment it if you want to have the turnserver running as
        # an automatic system service daemon
        #
        TURNSERVER_ENABLED=1    

`export $(TURN_IP4="magically determine the IP4 address of the active turn server, either turn.alpha.alta3.com or turn.bravo.alta3.com")`

`export $(TURN_IP6="magically determine the IP6 address of the active turn server, either turn.alpha.alta3.com or turn.bravo.alta3.com")`

`j2 /repo-dir/turnserver.conf.j2   /repo-dir/turnserver.conf`

`cp /repo-dir/turnserver.conf   /etc/turnserver.conf`

`sudo service coturn restart` 
