#!/usr/bin/bash

sed -i 's|${EXPORTER_MYSQL_PASSWORD}|'"$EXPORTER_MYSQL_PASSWORD"'|g' /docker-entrypoint-initdb.d/04-prometheus.sql