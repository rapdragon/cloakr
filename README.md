# Cloakr

Transmission torrent client running behind NordVPN in Docker.

## Features

- All traffic routed through NordVPN (OpenVPN)
- Kill-switch via iptables — drops traffic if VPN disconnects
- CIFS mounts for downloads and watch folder from TrueNAS

## Setup

Edit `docker-compose.yml` and fill in your values:

```yaml
environment:
  OPENVPN_USERNAME: <nordvpn-username>
  OPENVPN_PASSWORD: <nordvpn-password>
  NORDVPN_COUNTRY: US
  LOCAL_NETWORK: 10.69.0.0/16
```

```bash
docker compose up -d
```

Transmission web UI available at `http://<host>:9091`.
