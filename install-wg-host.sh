#!/bin/bash

HOST_IP=$1
CLIENT_IP=$2
DNS_IP=$3

apt-get update && apt-get install -y wireguard ufw curl
#fail2ban

# set up wireguard host
wg genkey | tee /etc/wireguard/privatekey | wg pubkey | tee /etc/wireguard/publickey

cat <<EOF >>/etc/wireguard/wg0.conf
[Interface]
Address = ${HOST_IP}/24
SaveConfig = true
ListenPort = 51820
PrivateKey = $(cat /etc/wireguard/privatekey)
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $(ip -o -4 route show to default | awk '{print $5}') -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $(ip -o -4 route show to default | awk '{print $5}') -j MASQUERADE
EOF

chmod 600 /etc/wireguard/privatekey
chmod 600 /etc/wireguard/wg0.conf

wg-quick up wg0

systemctl enable wg-quick@wg0

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

sysctl -p

# set up wireguard client1
mkdir -p /etc/wireguard/client1
wg genkey | tee /etc/wireguard/client1/privatekey | wg pubkey | tee /etc/wireguard/client1/publickey

cat <<EOF >>/etc/wireguard/client1/wg0.conf
[Interface]
PrivateKey = $(cat /etc/wireguard/client1/privatekey)
Address = ${CLIENT_IP}/24
DNS = ${DNS_IP}


[Peer]
PublicKey = $(cat /etc/wireguard/publickey)
Endpoint = $(curl icanhazip.com):51820
AllowedIPs = 0.0.0.0/0
EOF

wg set wg0 peer $(cat /etc/wireguard/client1/publickey) allowed-ips ${CLIENT_IP}

# set up firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 51820/udp
ufw enable
ufw status verbose

# TODO set up fail2ban also


# print client configs
echo "--------------"
echo "CLIENT CONFIGS"
echo "--------------"
echo ""
echo "copy to client in app or /etc/wireguard/wg0.conf"
cat /etc/wireguard/client1/wg0.conf
