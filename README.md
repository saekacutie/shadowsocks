# shadowsocks — Shadowsocks-WS behind OpenResty (Cloud Run)

Docker image that serves **Shadowsocks over WebSocket** through OpenResty on Cloud Run,
using Xray-core as the backend.

```
client ──TLS──> :8080 (openresty) ──/ss-ws──> 127.0.0.1:10000 (xray, shadowsocks)
```

## Files

| File | Purpose |
|---|---|
| `Dockerfile` | Multi-stage build (xray binary + openresty) |
| `xray-config.json` | Xray inbound: shadowsocks, ws, path `/ss-ws`, port 10000 |
| `nginx.conf` | OpenResty: `listen 8080`, proxies `/ss-ws` → xray |
| `entrypoint.sh` | Starts openresty, then xray |
| `deploy-ss.sh` | Interactive GCP deployer (builds, pushes, `gcloud run deploy`) |

## Deploy

```bash
chmod +x deploy-ss.sh
./deploy-ss.sh
```

Set `PASSWORD_INPUT` env var to choose the Shadowsocks password; otherwise a random
16-char password is generated and printed.

## Client

- Address: your Cloud Run URL (port 443)
- Path: `/ss-ws`
- Method/cipher: as printed by the deployer
