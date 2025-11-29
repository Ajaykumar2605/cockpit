#!/bin/bash

HOSTNAME_FQDN="serverA.redhat"
VALIDITY_DAYS=365
CERT_DIR="/etc/cockpit/ws-certs.d"

echo "=== Cockpit SSL Certificate Generator ==="
echo "Creating SSL certificate for CN: $HOSTNAME_FQDN"
sleep 1

mkdir -p $CERT_DIR
cd $CERT_DIR

# Generate key + CSR + self-signed certificate
openssl req -new -newkey rsa:4096 -nodes \
  -keyout ${HOSTNAME_FQDN}.key \
  -out ${HOSTNAME_FQDN}.csr \
  -subj "/CN=${HOSTNAME_FQDN}"

openssl x509 -req -days $VALIDITY_DAYS \
  -in ${HOSTNAME_FQDN}.csr \
  -signkey ${HOSTNAME_FQDN}.key \
  -out ${HOSTNAME_FQDN}.crt

# Rename to Cockpit required names
mv ${HOSTNAME_FQDN}.crt 1-cockpit.crt
mv ${HOSTNAME_FQDN}.key 1-cockpit.key

# Permissions
chmod 600 1-cockpit.key
chmod 644 1-cockpit.crt
chown root:root 1-cockpit.*

# Restart service
systemctl restart cockpit

echo "============================================="
echo " SSL Certificate Successfully Installed!"
echo " CN          : ${HOSTNAME_FQDN}"
echo " Valid Days  : ${VALIDITY_DAYS}"
echo " Location    : ${CERT_DIR}/"
echo " Browser URL : https://${HOSTNAME_FQDN}:9090"
echo "============================================="
