# ssh to the turn server first! 
if [[ `hostname` != "turn" ]]; then echo YOU ARE IN THE WRONG BOX ctrl-c is perfect right now; read; fi
sudo apt install git -y
echo ====================================================================================
echo HANDLE TLS CERTS
echo ====================================================================================
sudo apt install certbot -y
sudo certbot certonly --standalone -d turn.{{ cloud }}.alta3.com
sudo mkdir -p /etc/coturn/certs
echo copy the cert because COTURN will NOT follow symlinks created by letsencrypt
sudo cp /etc/letsencrypt/live/turn.{{ cloud }}.alta3.com/fullchain.pem /etc/coturn/certs/fullchain.pem
sudo cp /etc/letsencrypt/live/turn.{{ cloud }}.alta3.com/privkey.pem   /etc/coturn/certs/privkey.pem
cd /etc/coturn/certs/
echo JAMMY requires a DHPARAM file to prevent diffie hellman logjam attacks, so calculate one
echo COFFEE TIME (about five minutes)
sudo openssl dhparam -out dhparam4096.pem 4096
echo ===================================================================================
echo INSTALL COTURN
echo ===================================================================================
git clone https://github.com/alta3/sipgate.git
sudo apt install -y coturn 
sudo chown turnserver. /etc/coturn/certs/fullchain.pem
sudo chown turnserver. /etc/coturn/certs/privkey.pem
export TURN_IP4=$(hostname -I | awk '{print $1}')
sudo apt install -y j2cli
#j2 install on 20.04 and older
#sudo apt install pip
#python3 -m pip install j2cli
#PATH=$PATH:/home/ubuntu/.local/bin
j2 ~/sipgate/22.04/turn/turnserver.conf.j2 > ~/sipgate/22.04/turn/turnserver.conf
sudo cp ~/sipgate/22.04/turn/turnserver.conf /etc/turnserver.conf
sudo touch /var/log/turn.log
sudo chown turnserver. /var/log/turn.log
sudo systemctl restart coturn.service
echo Troubleshooting: sudo tail -f /var/log/turn.log
```
