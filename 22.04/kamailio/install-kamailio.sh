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

echo "Now run the script to create the certs."
cat <<EOF
Usage: $0 [output-directory]
Generate self-signed certificates for testing.
https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
EOF

[[ -z "$1" ]] && echo "Must provide output directory" && exit 1

CWD=$(pwd)
trap "cd $CWD;" EXIT

# create and change into output directory
OUTPUT_DIR="$1"
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

echo "Step 1: Generate CA private key"
echo "-------------------------------"
openssl genrsa -des3 -out ca.key 2048

echo
echo
echo "Step 2: Generate CA root certificate"
echo "------------------------------------"
openssl req -x509 -new -nodes -key ca.key -sha384 -days 36500 -out ca.pem -subj "/C=US/ST=PA/L=Harrisburg/CN=verisign.com/"

echo
echo
echo "Step 3: Generate a private key for kamailio server"
echo "--------------------------------------------------"
openssl genrsa -out cert.key 2048

echo
echo
echo "Step 4: Generate kamailio server certificate signing request"
echo "------------------------------------------------------------"
openssl req -new -key cert.key -out cert.csr -subj "/C=US/ST=PA/L=Harrisburg/CN=sipgate.alta3.com/"

echo
echo
echo "create config file"
>cert.ext cat <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
EOF

echo "Step 5: Create unsigned certificate for kamailio server"
echo "-------------------------------------------------------"
openssl req -x509 -new -nodes -key cert.key -sha384 -days 36500 -out cert.unsigned.pem -subj "/C=US/ST=PA/L=Harrisburg/CN=sipgate.alta3.com/"

echo
echo
echo "Step 6: Use key created in step 2"
echo "to sign the unsigned cert created"
echo "in step 5."
echo "---------------------------------"
openssl x509 -req -in cert.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out cert.pem -outform PEM -days 36500 -sha384 -extfile cert.ext

echo
echo
echo "Step 7: Store copy of certificate in pkcs12 format"
echo "pkcs12 format bundles private key with x509,"
echo "creating a chain of trust."
echo "--------------------------------------------------"
openssl pkcs12 -export -out cert.p12 -in cert.pem -inkey cert.key

echo
echo
echo "Step 8: Copying certs to kamailio directory."
echo "--------------------------------------------"
sudo cp ~/certs/cert.key /etc/kamailio/privkey.pem
sudo cp ~/certs/cert.pem /etc/kamailio/fullchain.pem

echo
echo
echo "Step 9: Chown keys in kamailio directory."
echo "--------------------------------------------"
sudo chown kamailio. /etc/kamailio/privkey.pem
sudo chown kamailio. /etc/kamailio/fullchain.pem


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
