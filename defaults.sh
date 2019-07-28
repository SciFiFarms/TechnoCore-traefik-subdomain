#!/bin/env bash

set_service_flag traefik-subdomain true

path_prefix INGRESS traefik

if [ -z "$TRAEFIK_DISABLE_BASIC_AUTH" ]; then
    export TRAEFIK_BASIC_AUTH=traefik.frontend.auth.basic.usersFile=/etc/traefik/usersfile
else
    export TRAEFIK_BASIC_AUTH=traefik.no.basic.auth
fi
