cd

git -C ~/sipgate/ pull

export MY_IP4=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')

export MY_DOMAIN="sipgate.alta3.com"

export MY_IP6=$(ip a s ens3 | awk -F"[/ ]+" '/inet6 / {print $3}')

export MY_INTERNAL_DOMAIN=$(

sudo apt install -y j2cli

j2 ~/sipgate/22.04/kamailio/kamailio.adam.cfg.j2 > ~/sipgate/22.04/kamailio/kamailio_update.cfg

sudo cp ~/sipgate/22.04/kamailio/kamailio_update.cfg /etc/kamailio/

sleep 5

sudo systemctl restart kamailio
