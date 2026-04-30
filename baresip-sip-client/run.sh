#!/usr/bin/env bash
set -e

# Config aus HA Optionen lesen
CONFIG_PATH=/data/options.json

SIP_SERVER=$(jq -r '.sip_server // "sip.placetel.de"' "$CONFIG_PATH")
SIP_USERNAME=$(jq -r '.sip_username // empty' "$CONFIG_PATH")
SIP_PASSWORD=$(jq -r '.sip_password // empty' "$CONFIG_PATH")
SIP_DISPLAYNAME=$(jq -r '.sip_displayname // "Home Assistant"' "$CONFIG_PATH")
HA_WEBHOOK=$(jq -r '.ha_webhook // empty' "$CONFIG_PATH")
HA_TOKEN=$(jq -r '.ha_token // empty' "$CONFIG_PATH")

echo "=== Baresip SIP Client for Home Assistant ==="
echo "Starting configuration..."

# Baresip Konfiguration erstellen
mkdir -p /etc/baresip

# accounts config
cat > /etc/baresip/accounts << EOF
<sip:${SIP_USERNAME}@${SIP_SERVER};auth_pass=${SIP_PASSWORD};displayname=${SIP_DISPLAYNAME}>
EOF

# config
cat > /etc/baresip/config << EOF
# Baresip Configuration
poll_method		select
sip_trans_bsize		128
sip_listen		0.0.0.0:5060
module			stdio.so
module			ice.so
module			stun.so
module			turn.so
module			sip.so
module			account.so
module			dtmf.so
module			menu.so
module			debug_cmd.so
module			httpd.so
module			aumix.so
module_app		menu.so
module_app		aumix.so
module_app		httpd.so
EOF

# modules config
cat > /etc/baresip/modules << EOF
stdio.so
ice.so
stun.so
sip.so
account.so
dtmf.so
menu.so
httpd.so
aumix.so
EOF

# contacts (leer)
touch /etc/baresip/contacts

echo "Configuration created."
echo "SIP Server: ${SIP_SERVER}"
echo "SIP Username: ${SIP_USERNAME}"

# Falls HA Webhook konfiguriert ist
if [ -n "$HA_WEBHOOK" ]; then
    echo "Setting up HA webhook integration..."
fi

echo "Starting baresip..."

# Baresip starten
exec baresip -f /etc/baresip -v 2>&1
