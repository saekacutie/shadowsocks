#!/bin/sh
/usr/local/openresty/bin/openresty -g 'daemon off;' &
sleep 2
exec /usr/local/bin/xray run -c /etc/xray/config.json
