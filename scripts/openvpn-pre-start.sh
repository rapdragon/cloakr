#!/bin/bash
set -e

echo "Applying kill switch iptables rules..."

# Drop all outbound by default
iptables -P OUTPUT DROP

# Allow loopback and already-established connections
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow traffic through the VPN tunnel (tun+)
iptables -A OUTPUT -o tun+ -j ACCEPT

# Allow OpenVPN to establish the connection (NordVPN TCP uses port 443)
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Allow ICMP — NordVPN setup script pings the CDN before downloading configs
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

# Allow DNS so OpenVPN can resolve the server hostname
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow LAN — web UI and Docker bridge access
iptables -A OUTPUT -d 10.69.0.0/16 -j ACCEPT
iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT

# Block IPv6 outbound entirely (avoid IPv6 leaks)
ip6tables -P OUTPUT DROP 2>/dev/null || true
ip6tables -A OUTPUT -o lo -j ACCEPT 2>/dev/null || true
ip6tables -A OUTPUT -o tun+ -j ACCEPT 2>/dev/null || true
ip6tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true

echo "Kill switch active — all traffic blocked except through VPN tunnel."
