# Cloakr

Transmission torrent client running behind NordVPN in Docker.

## Features

- All traffic routed through NordVPN (OpenVPN)
- Kill-switch via iptables — drops traffic if VPN disconnects
- CIFS volume support for downloads and watch folder from network storage

## Setup

### 1. Configure environment

**Docker Compose:** Create a `.env` file in the same directory as `docker-compose.yml`:

```env
OPENVPN_USERNAME=your-nordvpn-username
OPENVPN_PASSWORD=your-nordvpn-password
```

**TrueNAS Scale:** Since this is a custom app, env vars are embedded in the compose file. Go to Apps → cloakr → Edit and update the `environment:` section directly in the compose editor:

```yaml
services:
  cloakr:
    image: haugene/transmission-openvpn:latest
    container_name: cloakr
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    restart: unless-stopped
    ports:
      - "9091:9091"
    environment:
      OPENVPN_PROVIDER: NORDVPN
      OPENVPN_USERNAME: john.doe@example.com
      OPENVPN_PASSWORD: hunter2
      NORDVPN_COUNTRY: US
      NORDVPN_PROTOCOL: TCP
      LOCAL_NETWORK: 192.168.1.0/24
      TZ: America/New_York
      PUID: "1000"
      PGID: "1000"
      TRANSMISSION_DOWNLOAD_DIR: /downloads
      TRANSMISSION_INCOMPLETE_DIR: /data/incomplete
      TRANSMISSION_INCOMPLETE_DIR_ENABLED: "true"
      TRANSMISSION_WATCH_DIR_FORCE_GENERIC: "true"
    volumes:
      - ./data:/data
      - ./scripts:/scripts
      - downloads:/downloads
      - watch:/data/watch
volumes:
  downloads:
  watch:
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
