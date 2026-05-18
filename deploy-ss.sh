#!/bin/bash
# ==============================================
# SHADOWSOCKS WS TLS GCP AUTO DEPLOYER (Nginx Stealth)
# created by prvtspyyy
# ==============================================

# --- ANSI colour definitions ---
BOLD='\033[1m'; RESET='\033[0m'
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'; WHITE='\033[0;37m'
LRED='\033[1;31m'; LGREEN='\033[1;32m'; LYELLOW='\033[1;33m'
LBLUE='\033[1;34m'; LMAGENTA='\033[1;35m'; LCYAN='\033[1;36m'; LWHITE='\033[1;37m'
C_SUCCESS="${BOLD}${LGREEN}"; C_ERROR="${BOLD}${LRED}"
C_WARN="${BOLD}${LYELLOW}"; C_INFO="${BOLD}${LCYAN}"
C_HEADER="${BOLD}${LMAGENTA}"; C_ACCENT="${BOLD}${LBLUE}"; C_PLAIN="${BOLD}${WHITE}"

rainbow_banner() {
    clear
    echo ""
    echo -e "${BOLD}${LRED}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                                                                            ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}  ${BOLD}${WHITE}███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗███████╗██╗  ██╗${LRED}  ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}  ${BOLD}${WHITE}██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║██╔════╝██║ ██╔╝${LRED}  ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}  ${BOLD}${WHITE}███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║███████╗█████╔╝ ${LRED}  ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}  ${BOLD}${WHITE}╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║╚════██║██╔═██╗ ${LRED}  ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}  ${BOLD}${WHITE}███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝███████║██║  ██╗${LRED}  ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}  ${BOLD}${WHITE}╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝${LRED}  ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                                                                            ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}           ${BOLD}${WHITE}SHADOWSOCKS WS TLS DEPLOYER${RESET}                                   ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}           ${CYAN}Cloud Run Ultra-Stealth Edition${RESET}                              ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}           ${CYAN}created by prvtspyyy${RESET}                                           ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

check_gcloud() {
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${C_PLAIN}PROJECT & API VERIFICATION${RESET}"
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

    ACCOUNT=$(gcloud auth list --format="value(account)" 2>/dev/null | head -1)
    if [ -z "$ACCOUNT" ]; then
        echo -e "${C_ERROR}[✘]${RESET} Not logged in. Run: gcloud auth login"
        exit 1
    fi
    echo -e "${C_SUCCESS}[✔]${RESET} Logged in as: ${BOLD}${ACCOUNT}${RESET}"

    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$PROJECT_ID" ]; then
        echo -e "${C_ERROR}[✘]${RESET} No project set. Run: gcloud config set project PROJECT_ID"
        exit 1
    fi
    echo -e "${C_SUCCESS}[✔]${RESET} Project: ${BOLD}${PROJECT_ID}${RESET}"

    for api in "run.googleapis.com" "cloudbuild.googleapis.com"; do
        echo -ne "${C_INFO}[*]${RESET} Enabling ${api}...\r"
        gcloud services enable "$api" --quiet 2>/dev/null
        echo -e "${C_SUCCESS}[✔]${RESET} ${api} enabled"
    done
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo ""
}

gather_config() {
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${C_PLAIN}REGION SELECTION${RESET}"
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e " ${C_ACCENT}[1]${RESET} us-central1"
    echo -e " ${C_ACCENT}[2]${RESET} us-east1"
    echo -e " ${C_ACCENT}[3]${RESET} asia-east1"
    echo -e " ${C_ACCENT}[4]${RESET} asia-southeast1"
    echo -e " ${C_ACCENT}[5]${RESET} europe-west1"
    echo -e " ${C_ACCENT}[6]${RESET} europe-west4"
    read -p "$(echo -e "${C_INFO}[?]${RESET} Select region [1-6] (default: us-central1): ")" REGION_CHOICE
    case "${REGION_CHOICE:-1}" in
        1) REGION="us-central1" ;; 2) REGION="us-east1" ;; 3) REGION="asia-east1" ;;
        4) REGION="asia-southeast1" ;; 5) REGION="europe-west1" ;; 6) REGION="europe-west4" ;;
        *) REGION="us-central1" ;;
    esac
    echo -e "${C_SUCCESS}[✔]${RESET} Region: ${BOLD}${REGION}${RESET}"
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo ""

    read -p "$(echo -e "${C_INFO}[?]${RESET} Service name (default: shadowsocks-ws): ")" SERVICE_NAME_INPUT
    SERVICE_NAME="${SERVICE_NAME_INPUT:-shadowsocks-ws}"
    SERVICE_NAME=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    if [ -z "$SERVICE_NAME" ]; then SERVICE_NAME="shadowsocks-ws"; fi
    echo -e "${C_SUCCESS}[✔]${RESET} Service name: ${BOLD}${SERVICE_NAME}${RESET}"
    echo ""

    read -p "$(echo -e "${C_INFO}[?]${RESET} Password (default: auto-generated): ")" PASSWORD_INPUT
    PASSWORD="${PASSWORD_INPUT:-$(tr -dc A-Za-z0-9 </dev/urandom | head -c16)}"
    echo -e "${C_SUCCESS}[✔]${RESET} Password: ${BOLD}${PASSWORD}${RESET}"
    echo ""

    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${C_PLAIN}CPU AND MEMORY SELECTION${RESET}"
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e " ${C_ACCENT}[1]${RESET} 1 vCPU, 512Mi (free tier)"
    echo -e " ${C_ACCENT}[2]${RESET} 1 vCPU, 1Gi"
    echo -e " ${C_ACCENT}[3]${RESET} 2 vCPU, 2Gi"
    echo -e " ${C_ACCENT}[4]${RESET} 2 vCPU, 4Gi (recommended)"
    echo -e " ${C_ACCENT}[5]${RESET} 4 vCPU, 8Gi"
    echo -e " ${C_ACCENT}[6]${RESET} 4 vCPU, 16Gi"
    read -p "$(echo -e "${C_INFO}[?]${RESET} Choose config [1-6] (default: 4): ")" CPU_RAM_CHOICE
    CPU_RAM_CHOICE="${CPU_RAM_CHOICE:-4}"
    case $CPU_RAM_CHOICE in
        1) CPU="1"; MEMORY="512Mi" ;; 2) CPU="1"; MEMORY="1Gi" ;;
        3) CPU="2"; MEMORY="2Gi" ;; 4) CPU="2"; MEMORY="4Gi" ;;
        5) CPU="4"; MEMORY="8Gi" ;; 6) CPU="4"; MEMORY="16Gi" ;;
        *) CPU="2"; MEMORY="4Gi" ;;
    esac
    echo -e "${C_SUCCESS}[✔]${RESET} CPU: ${BOLD}${CPU}${RESET}, Memory: ${BOLD}${MEMORY}${RESET}"
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo ""

    read -p "$(echo -e "${C_INFO}[?]${RESET} Decoy domain (e.g. smart.com.ph): ")" DECOY_DOMAIN
    DECOY_DOMAIN="${DECOY_DOMAIN:-smart.com.ph}"
    echo -e "${C_SUCCESS}[✔]${RESET} Decoy domain: ${BOLD}${DECOY_DOMAIN}${RESET}"
    echo ""

    read -p "$(echo -e "${C_INFO}[?]${RESET} WS path (default: /ss-ws): ")" WS_PATH_INPUT
    WS_PATH="${WS_PATH_INPUT:-/ss-ws}"
    echo -e "${C_SUCCESS}[✔]${RESET} WS path: ${BOLD}${WS_PATH}${RESET}"
    echo ""
}

deploy() {
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${C_PLAIN}SHADOWSOCKS DEPLOYMENT${RESET}"
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

    BUILD_DIR=$(mktemp -d)
    cd "$BUILD_DIR"

    # Xray config — Shadowsocks inbound on internal port, Nginx handles TLS + decoy
    cat <<EOF > xray-config.json
{
  "log": {"loglevel": "none"},
  "inbounds": [
    {
      "port": 10000,
      "listen": "127.0.0.1",
      "protocol": "shadowsocks",
      "settings": {
        "method": "aes-256-gcm",
        "password": "$PASSWORD",
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "$WS_PATH"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {"domainStrategy": "UseIPv4"},
      "streamSettings": {
        "sockopt": {
          "tcpFastOpen": true,
          "tcpKeepAliveInterval": 30
        }
      }
    }
  ]
}
EOF

    # Nginx — TLS termination, decoy site, WebSocket proxy to Xray
    cat <<'NGINXEOF' > nginx.conf
worker_processes auto;
events { worker_connections 1024; }

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    server {
        listen 8080;
        server_name _;

        # Decoy: visitors see the external site
        location / {
            proxy_pass https://DECOY_PLACEHOLDER;
            proxy_ssl_server_name on;
            proxy_set_header Host DECOY_PLACEHOLDER;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_pass_header Set-Cookie;
            proxy_pass_header Server;
        }

        # Shadowsocks WebSocket endpoint
        location = SSPATH_PLACEHOLDER {
            if ($http_upgrade != "websocket") {
                return 404;
            }
            proxy_pass http://127.0.0.1:10000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 86400s;
            proxy_send_timeout 86400s;
            proxy_buffering off;
            proxy_request_buffering off;
            tcp_nodelay on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            proxy_temp_file_write_size 256k;
        }
    }
}
NGINXEOF
    sed -i "s|DECOY_PLACEHOLDER|$DECOY_DOMAIN|g" nginx.conf
    sed -i "s|SSPATH_PLACEHOLDER|$WS_PATH|g" nginx.conf

    cat <<'ENTRYEOF' > entrypoint.sh
#!/bin/sh
/usr/local/openresty/bin/openresty -g 'daemon off;' &
sleep 2
exec /usr/local/bin/xray run -c /etc/xray/config.json
ENTRYEOF
    chmod +x entrypoint.sh

    cat <<'DOCKEREOF' > Dockerfile
FROM teddysun/xray:latest AS xray-bin
FROM openresty/openresty:alpine-fat
RUN apk add --no-cache curl
COPY --from=xray-bin /usr/bin/xray /usr/local/bin/xray
COPY xray-config.json /etc/xray/config.json
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/xray
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
DOCKEREOF

    IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME"

    echo -e "${C_INFO}[*]${RESET} Building container with Cloud Build..."
    if ! gcloud builds submit --tag "$IMAGE" . --quiet 2>&1 | tail -5; then
        echo -e "${C_ERROR}[✘]${RESET} Build failed."
        cd ~; rm -rf "$BUILD_DIR"
        return 1
    fi
    echo -e "${C_SUCCESS}[✔]${RESET} Build successful"

    echo -e "${C_INFO}[*]${RESET} Deploying to Cloud Run..."
    gcloud run deploy "$SERVICE_NAME" \
        --image "$IMAGE" \
        --platform managed \
        --region "$REGION" \
        --allow-unauthenticated \
        --port 8080 \
        --cpu "$CPU" \
        --memory "$MEMORY" \
        --concurrency 1 \
        --timeout 3600 \
        --min-instances 1 \
        --max-instances 1 \
        --no-cpu-throttling \
        --session-affinity \
        --quiet

    SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)')
    CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

    echo ""
    echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${BOLD}${WHITE}SHADOWSOCKS DEPLOYED${RESET}"
    echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}Address:${RESET} ${BOLD}${CLEAN_HOST}${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}Port:${RESET}    443"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}Password:${RESET} ${BOLD}${PASSWORD}${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}Method:${RESET}   aes-256-gcm"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}Path:${RESET}    ${BOLD}${WS_PATH}${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}Network:${RESET} ws (WebSocket), TLS: Yes"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}Decoy:${RESET}   ${BOLD}${DECOY_DOMAIN}${RESET}"
    echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo "Shadowsocks SIP008 URL:"
    echo "ss://$(echo -n "aes-256-gcm:${PASSWORD}@${CLEAN_HOST}:443?plugin=v2ray-plugin;tls;host=${CLEAN_HOST};path=${WS_PATH}" | base64 -w0)#${SERVICE_NAME}"
    echo ""

    cd ~; rm -rf "$BUILD_DIR"
    return 0
}

# Run
rainbow_banner
check_gcloud
gather_config
deploy
