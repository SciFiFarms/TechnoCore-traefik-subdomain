#!/bin/env bash

set_service_flag traefik-subdomain true

prefix=traefik

if [ -z "$TRAEFIK_DISABLE_BASIC_AUTH" ]; then
    export TRAEFIK_BASIC_AUTH=traefik.frontend.auth.basic.usersFile=/etc/traefik/usersfile
    # For Traefik 2.0. 
    #export TRAEFIK_BASIC_AUTH=traefik.http.middlewares.myAuth.basicauth.usersFile=/etc/traefik/usersfile
    #export TRAEFIK_BASIC_AUTH_MIDDLEWARE=traefik.http.routers.api.middlewares=myAuth
else
    export TRAEFIK_BASIC_AUTH=traefik.no.basic.auth
    # For Traefik 2.0. 
    #export TRAEFIK_BASIC_AUTH_MIDDLEWARE=traefik.http.routers.api.middlewares=myAuth
fi
