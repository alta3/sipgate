echo

sudo apt install j2cli -y

export RTPE_PORT_MIN=`cat ~/portmin`

export RTPE_PORT_MAX=`cat ~/portmax`

export MY_CLOUD=$(nslookup 10.0.0.1 | grep -oP 'alpha|bravo')

export MY_FQDN="live.$MY_CLOUD.alta3.com"

export MY_OUTSIDE_IP=$(dig @8.8.8.8 $MY_FQDN +short )

export MY_IP4_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')

j2 ~/sipgate/22.04/rtpengine/rtpengine.conf.j2 > ~/sipgate/22.04/rtpengine/rtpengine.conf

sudo cp ~/sipgate/22.04/rtpengine/rtpengine.conf /etc/rtpengine/rtpengine.conf

sudo systemctl restart ngcp-rtpengine-daemon
