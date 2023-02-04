`ssh to the turn server`

`sudo apt install git`

`cd`

`git clone https://github.com/alta3/sipgate.git`

`sudo apt install -y coturn`

`sudo cp ~/sipgate/22.04/coturn  /etc/default/coturn`

`export TURN_IP4=$(hostname -I | awk '{print $1}')`

`j2 /repo-dir/turnserver.conf.j2   /repo-dir/turnserver.conf`

`cp /repo-dir/turnserver.conf   /etc/turnserver.conf`

`sudo chmod g+w turn.log`

`sudo chown root:turnserver turn.log`

`sudo service coturn restart` 
