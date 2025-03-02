# !/bin/bash

docker compose \
    -f docker-compose.yml \
    -f services/watchtower/docker-compose.yml \
    -f services/traefik/docker-compose.yml \
    -f services/mysql/docker-compose.yml \
    -f services/redis/docker-compose.yml \
    -f services/prometheus/docker-compose.yml \
    -f services/grafana/docker-compose.yml \
    -f services/portainer/docker-compose.yml \
    -f services/wings/docker-compose.yml \
    -f services/panel/docker-compose.yml \
    down
    