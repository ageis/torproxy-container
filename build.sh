#!/bin/bash
export DOCKER_HOST="unix:///var/run/docker.sock"
export TOR_CONTROL_PASSWD="$(openssl rand -hex 16)"
docker-compose --file files/docker-compose.yml --project-directory files --project-name torproxy --verbose --log-level INFO --host "${DOCKER_HOST}"  build --no-cache --compress --build-arg TOR_CONTROL_PASSWD=${TOR_CONTROL_PASSWD}
docker-compose --file files/docker-compose.yml --project-directory files --project-name torproxy --verbose --log-level INFO --host "${DOCKER_HOST}"  up --detach torproxy



