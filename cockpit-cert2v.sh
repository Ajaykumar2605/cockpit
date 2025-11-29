#!/bin/bash

# === Auto-detect hostname / FQDN ===
AUTO_HOST=$(hostname -f 2>/dev/null)
if [[ "$AUTO_HOST" == *.* ]]; then
  HOSTNAME_FQDN="$AUTO_HOST"
else
  PUBIP=$(curl -s https://api.ipify.org || true)
  HOSTNAME_FQDN="${PUBIP:-localhost}"
fi

VALIDITY_DAYS=365
CERT_DIR="/etc/cockpit/ws-certs.d"

echo "=== Cockpit SSL Certificate Generator ==="
echo "Detected Hostname: $HOSTNAME_FQDN"
echo "Generating certificate..."
sleep 1

mkdir -p $CERT_DIR
cd $CERT_DIR

# Generate key + CSR + self-signed certificate (as temp names)
openssl req -new -newkey rsa:4096 -nodes \
  -keyout temp.key \
  -out temp.csr \
  -subj "/CN=${HOSTNAME_FQDN}"

openssl x509 -req -days $VALIDITY_DAYS \
  -in temp.csr \
  -signkey temp.key \
  -out temp.crt

# Move to Cockpit required filenames
mv -f temp.crt cockpit-server.crt
mv -f temp.key cockpit-server.key

# Cleanup
rm -f temp.csr

# Permissions
chmod 600 cockpit-server.key
chmod 644 cockpit-server.crt
chown root:root cockpit-server.*

# Restart Cockpit
systemctl restart cockpit

echo "============================================="
echo " SSL Certificate Successfully Installed!"
echo " CN          : ${HOSTNAME_FQDN}"
echo " Valid Days  : ${VALIDITY_DAYS}"
echo " Location    : ${CERT_DIR}/"
echo " Browser URL : https://${HOSTNAME_FQDN}:9090"
echo "============================================="
