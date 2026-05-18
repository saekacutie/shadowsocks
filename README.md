# Shadowsocks WebSocket TLS - Google Cloud Run

Automated Shadowsocks deployment with Nginx reverse proxy and TLS termination on Google Cloud Run.

## Features

- 🔒 **Shadowsocks Protocol** - aes-256-gcm encryption
- 🌐 **WebSocket Support** - ws:// over TLS
- 🎭 **Decoy Website** - masquerade as legitimate domain
- ⚡ **Ultra-fast** - OpenResty + Xray
- 🏃 **Cloud Run Ready** - fully containerized, auto-scaling
- 🔄 **Simple Deployment** - one-command auto deployer

## Quick Start

### Prerequisites

```bash
# Install Google Cloud SDK
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Deploy

```bash
chmod +x deploy-ss.sh
./deploy-ss.sh
```

The script will:
1. Verify GCP authentication and APIs
2. Prompt for region and configuration
3. Build Docker image with Cloud Build
4. Deploy to Cloud Run
5. Output connection details and SIP008 URL

## Configuration

### During Deployment

- **Region**: Choose from 6 global regions
- **Service Name**: Unique identifier (auto-sanitized)
- **Password**: Auto-generated or custom
- **CPU/Memory**: 1 vCPU/512Mi to 4 vCPU/16Gi
- **Decoy Domain**: Website to masquerade as
- **WebSocket Path**: Custom path (default: `/ss-ws`)

### Output Example

```
Address:    vmess-ws-abcd.run.app
Port:       443
Password:   GeneratedPassword123
Method:     aes-256-gcm
Path:       /ss-ws
Network:    ws (WebSocket), TLS: Yes
Decoy:      smart.com.ph

Shadowsocks SIP008 URL:
ss://YWVzLTI1Ni1nY206UGFzc3dvcmRAbXZlc3MtYWJjZC5ydW4uYXBwOjQ0Mz9wbHVnaW49djJyYXktcGx1Z2luO3Rscztob3N0PW12ZXNzLWFiY2QucnVuLmFwcDtwYXRoPSUyRnNzLXdzI3NlcnZpY2VOYW1l
```

## File Structure

- **Dockerfile** - Multi-stage build with Xray and OpenResty
- **nginx.conf** - Reverse proxy, WebSocket, decoy routing
- **xray-config.json** - Shadowsocks protocol configuration
- **entrypoint.sh** - Container startup script
- **deploy-ss.sh** - GCP deployment automation

## Architecture

```
Client (Shadowsocks) 
   ↓ (TLS/WS)
Cloud Run Service
   ↓
Nginx (Port 8080)
   ├→ /ss-ws → Xray (Port 10000) → Freedom Outbound
   └→ / → smart.com.ph (Decoy)
```

## Troubleshooting

### Build Failed
- Check Cloud Build API is enabled: `gcloud services enable cloudbuild.googleapis.com`
- Verify project has Container Registry enabled

### Connection Issues
- Ensure health check passes: `curl https://SERVICE_URL/health`
- Check Cloud Run logs: `gcloud run services describe SERVICE_NAME --region REGION`

### High Latency
- Select region closest to your location
- Increase CPU/Memory allocation

## Security Notes

⚠️ **Important**: This is for educational purposes only. Ensure you comply with local laws and regulations.

- Change decoy domain to something legitimate
- Use strong passwords
- Monitor Cloud Run logs for suspicious activity
- Set appropriate IAM policies

## License

MIT
