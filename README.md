# Cloakr

Transmission torrent client running behind NordVPN in Docker.

## Features

- All traffic routed through NordVPN (OpenVPN)
- Kill-switch via iptables — drops traffic if VPN disconnects
- CIFS volume support for downloads and watch folder from network storage

## Setup

### 1. Configure environment

Create a `.env` file with your NordVPN credentials:

```env
OPENVPN_USERNAME=your-nordvpn-username
OPENVPN_PASSWORD=your-nordvpn-password
```

### 2. Configure volumes

By default `docker-compose.yml` uses plain named volumes. For network storage (e.g. TrueNAS/NAS via CIFS), replace the volume definitions:

```yaml
volumes:
  downloads:
    driver: local
    driver_opts:
      type: cifs
      device: //<nas-ip>/share/downloads
      o: "noperm,username=<user>,password=<pass>,vers=3.1.1"
  watch:
    driver: local
    driver_opts:
      type: cifs
      device: //<nas-ip>/share/torrent
      o: "noperm,username=<user>,password=<pass>,vers=3.1.1"
```

### 3. Run

```bash
docker compose up -d
```

Transmission web UI available at `http://<host>:9091`.

## Configuration

| Variable | Default | Description |
|---|---|---|
| `OPENVPN_USERNAME` | required | NordVPN username |
| `OPENVPN_PASSWORD` | required | NordVPN password |
| `NORDVPN_COUNTRY` | `US` | VPN exit country |
| `NORDVPN_PROTOCOL` | `TCP` | OpenVPN protocol |
| `LOCAL_NETWORK` | `10.69.0.0/16` | LAN range excluded from VPN kill-switch |
| `TZ` | `America/Denver` | Timezone |
| `PUID` / `PGID` | `568` | User/group for file permissions |
