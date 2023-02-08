cd
git clone https://github.com/alta3/sipgate.git
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo apt install -y kamailio
sudo apt install -y kamailio-mysql-modules
sudo apt install -y kamailio-websocket-modules
sudo apt install -y kamailio-tls-modules
sudo apt install -y kamailio-extra-modules
sudo apt install -y kamailio-json-modules

bash /home/student/sipgate/22.04/kamailio/make-test-cert.sh /etc/kamailio/

export MY_IP4_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')
export MY_DOMAIN="sipgate.alta3.com"
export MY_IP6_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet6 / {print $3}')
sudo apt install -y j2cli
j2 ~/sipgate/22.04/kamailio/kamailio.cfg.j2 > ~/sipgate/22.04/kamailio/kamailio.cfg
j2 ~/sipgate/22.04/kamailio/kamctlrc.j2 > ~/sipgate/22.04/kamailio/kamctlrc
sudo cp ~/sipgate/22.04/kamailio/kamailio.cfg /etc/kamailio/
sudo cp ~/sipgate/22.04/kamailio/kamctlrc     /etc/kamailio/
sudo cp ~/sipgate/22.04/kamailio/tls.cfg      /etc/kamailio/

echo "Use alta3 as your password."
sudo kamdbctl create

sudo systemctl enable kamailio
sleep 5
sudo systemctl restart kamailio
sudo kamctl add 2001 2001regpass
sudo kamctl add 2002 2002regpass
