#!/bin/bash
docker build --no-cache --compress --add-host torproxy:127.0.0.1 --label 'tor' --network host -t torproxy .
cd files && docker-compose up -d --force-recreate torproxy



