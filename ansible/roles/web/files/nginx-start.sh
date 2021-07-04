#!/bin/bash
/usr/bin/docker run \
  --restart=on-failure:5 \
  --network="bridge" \
  -v /root/index.html:/usr/share/nginx/html/index.html \
  -p 80:80 \
  --name=nginx-web \
  nginx:1.21.0-alpine \
  "$@"
