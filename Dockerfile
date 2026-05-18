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
