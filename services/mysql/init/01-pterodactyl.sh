#!/usr/bin/bash

sed -i 's|${PANEL_MYSQL_PASSWORD}|'"$PANEL_MYSQL_PASSWORD"'|g' /docker-entrypoint-initdb.d/02-pterodactyl.sql