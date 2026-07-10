#!/bin/bash

# Get location of current file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find First Wlan interface
WLAN_INTERFACE=$(ip addr | grep -oP '^\d+: \K\w+(?=: <BROADCAST,MULTICAST,UP,LOWER_UP>)')
# Get IP
IP_ADDRESSES=$(ip addr show dev "$WLAN_INTERFACE" | grep -Po 'inet \K[\d.]+' | tr '\n' ' ')
IP_ADDRESS=$(cut -d" " -f1 <<< $IP_ADDRESSES)

clear

# IP exist or not
if [ -z "$IP_ADDRESS" ]; then
	echo "IP address is not detected!"
	read -p "Please enter the IP address or just press Enter to exit: " IP_ADDRESS
	if [ -z "$IP_ADDRESS" ]; then
		exit
	fi
fi

# Generate SSL certificate if is not exist for https connection
if [ ! -f "$SCRIPT_DIR/ssl/key.pem" ] || [ ! -f "$SCRIPT_DIR/ssl/cert.pem" ]; then
	echo "Generating SSL certificates..."
	openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 123456 -nodes \
		-subj "/C=US/ST=State/L=Locality/O=Organization/CN=localhost"
	echo "SSL generated successfully."
fi

# Show server qr-code
if command -v qrencode &>/dev/null; then
	qrencode -t ansiutf8 "https://$IP_ADDRESS:80"
elif command -v qr &>/dev/null; then
	qr "https://$IP_ADDRESS:80"
else
	echo "Both \"QREncode\" and \"QR\" packages is not installed, QRCode can not be showen"
	echo "Open [https://$IP_ADDRESS:80] in your browser to connect to the server."
fi
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo "IP Address: ${IP_ADDRESSES}"
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"

# Run virtual gamepad server
sudo $(which node) $SCRIPT_DIR/main.js
