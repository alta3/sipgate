echo "You will be prompted for RTPE_PORT_MIN and RTPE_PORT_MAX."
echo "These values will be supplied by your instructor."
echo
read -p "Press Enter when ready."

export RTPE_PORT_MIN=`cat ~/portmin`

export RTPE_PORT_MAX=`cat ~/portmax`

if [[ -z "$RTPE_PORT_MIN" ]] ; then  echo "ERROR: RTPE_PORT_MIN not set" ; fi

if [[ -z "$RTPE_PORT_MAX" ]] ; then  echo "ERROR: RTPE_PORT_MAX not set" ; fi

export TURN_CLOUD=$(nslookup 10.0.0.1 | grep -oP alpha||bravo)

export TURN_FQDN="turn.$TURN_CLOUD.alta3.com"

export MY_OUTSIDE_IP=$(dig +short $TURN_FQDN)

export MY_IP4_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')

j2 ~/sipgate/22.04/rtpengine/rtpengine.conf.j2 > ~/sipgate/22.04/rtpengine/rtpengine.conf

sudo cp ~/sipgate/22.04/rtpengine/rtpengine.conf /etc/rtpengine/rtpengine.conf

sudo systemctl restart ngcp-rtpengine-daemon
