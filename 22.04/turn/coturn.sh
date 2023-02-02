`ssh to the turn server`

`sudo apt install git`

`cd`

`git clone https://github.com/alta3/sipgate.git`

`sudo apt install -y coturn`

`sudo cp ~/sipgate/22.04/coturn  /etc/default/coturn`

`export TURN_IP4=$(hostname -I | awk '{print $1}')`

`export $(TURN_IP6="magically determine the IP6 address of the active turn server, either turn.alpha.alta3.com or turn.bravo.alta3.com")`

`j2 /repo-dir/turnserver.conf.j2   /repo-dir/turnserver.conf`

`cp /repo-dir/turnserver.conf   /etc/turnserver.conf`

`sudo service coturn restart` 
