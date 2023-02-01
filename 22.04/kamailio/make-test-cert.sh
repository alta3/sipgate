#!/usr/bin/env bash

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

echo "generate CA private key"
openssl genrsa -des3 -out ca.key 2048

echo "generate root certificate"
openssl req -x509 -new -nodes -key ca.key -sha384 -days 36500 -out ca.pem

echo "generate a private key for certificates"
openssl genrsa -out cert.key 2048

echo "generate a certificate signing request"
openssl req -new -key cert.key -out cert.csr

echo "create config file"
>cert.ext cat <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = localhost
EOF

echo "create unsigned certificate"
openssl req -x509 -new -nodes -key cert.key -sha384 -days 36500 -out cert.unsigned.pem

echo "create signed certificate"
openssl x509 -req -in cert.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out cert.pem -outform PEM -days 36500 -sha384 -extfile cert.ext

echo "store copy of certificate in pkcs12 format"
openssl pkcs12 -export -out cert.p12 -in cert.pem -inkey cert.key

echo "create expired certificate"
openssl x509 -req -in cert.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out cert.expired.pem -days -1 -sha384 -extfile cert.ext
