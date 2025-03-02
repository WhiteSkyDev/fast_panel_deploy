#!/usr/bin/bash

sed -i 's|${GRAFANA_MYSQL_PASSWORD}|'"$GRAFANA_MYSQL_PASSWORD"'|g' /docker-entrypoint-initdb.d/06-grafana.sql