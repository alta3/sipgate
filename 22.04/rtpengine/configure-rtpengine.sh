echo

sudo apt install j2cli -y

export RTPE_PORT_MIN=`cat ~/portmin`

export RTPE_PORT_MAX=`cat ~/portmax`

export TURN_CLOUD=$(nslookup 10.0.0.1 | grep -oP 'alpha|bravo')

export TURN_FQDN="turn.$TURN_CLOUD.alta3.com"

export MY_OUTSIDE_IP=$(dig +short $TURN_FQDN)

export MY_IP4_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')

j2 ~/sipgate/22.04/rtpengine/rtpengine.conf.j2 > ~/sipgate/22.04/rtpengine/rtpengine.conf

sudo cp ~/sipgate/22.04/rtpengine/rtpengine.conf /etc/rtpengine/rtpengine.conf

sudo systemctl restart ngcp-rtpengine-daemon
