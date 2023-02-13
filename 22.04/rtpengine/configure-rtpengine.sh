if [[ -z "$(RTPE_PORT_MAX)" ]]

export TURN_CLOUD=$(nslookup 10.0.0.1 | grep -oP alpha||bravo)

export TURN_FQDN="turn.$TURN_CLOUD.alta3.com"

export MY_OUTSIDE_IP=$(dig +short $TURN_FQDN)

export MY_IP4_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')
