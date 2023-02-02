cd
git clone https://github.com/alta3/sipgate.git
sudo apt install mariadb-server kamailio  -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo apt install kamailio
sudo apt install kamailio-mysql-modules
sudo apt install kamailio-websocket-modules
sudo apt install kamailio-tls-modules kamailio-extra-modules -y
sudo apt install kamailio-json-modules -y
sudo systemctl enable kamailio
export MY_IP4_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')
export MY_DOMAIN="sipgate.alta3.com"
export MY_IP6_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet6 / {print $3}')
sudo apt install -y j2cli
j2 ~/sipgate/22.04/kamailio/kamailio.cfg.j2 > ~/sipgate/22.04/kamailio/kamailio.cfg
j2 ~/sipgate/22.04/kamailio/kamctlrc.j2 > ~/sipgate/22.04/kamailio/kamctlrc
sudo cp ~/sipgate/22.04/kamailio/kamailio.cfg /etc/kamailio/
sudo cp ~/sipgate/22.04/kamailio/kamctlrc     /etc/kamailio/
sudo cp ~/sipgate/22.04/kamailio/tls.cfg      /etc/kamailio/
sleep 5
sudo systemctl restart kamailio
