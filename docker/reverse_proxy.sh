#!/usr/bin/env bash

docker run -d -p 80:80 -p 443:443 --name proxy \
    -v /etc/wcerts/:/etc/nginx/certs:ro \
    -v /etc/nginx/vhost.d \
    -v /usr/share/nginx/html \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -v ~/nginx/my_proxy.conf:/etc/nginx/conf.d/my_proxy.conf:ro \
    --restart always \
    jwilder/nginx-proxy && \

docker run -d --name certifier \
    --volumes-from proxy \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /etc/wcerts:/etc/nginx/certs:rw \
    --restart always \
    jrcs/letsencrypt-nginx-proxy-companion:stable
