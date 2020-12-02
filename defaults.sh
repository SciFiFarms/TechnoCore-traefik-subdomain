#!/bin/env bash

set_service_flag traefik-subdomain true

prefix=traefik

if [ -z "$TRAEFIK_DISABLE_BASIC_AUTH" ]; then
    export TRAEFIK_BASIC_AUTH=traefik.frontend.auth.basic.usersFile=/etc/traefik/usersfile
    export TRAEFIK_BASIC_AUTH_REMOVE_HEADERS=traefik.frontend.auth.basic.removeHeader=true
    # For Traefik 2.0. 
    #export TRAEFIK_BASIC_AUTH=traefik.http.middlewares.myAuth.basicauth.usersFile=/etc/traefik/usersfile
    #export TRAEFIK_BASIC_AUTH_MIDDLEWARE=traefik.http.routers.api.middlewares=myAuth
else
    export TRAEFIK_BASIC_AUTH=traefik.no.basic.auth=true
    export TRAEFIK_BASIC_AUTH_REMOVE_HEADERS=traefik.no.basic.auth.headers=true
    # For Traefik 2.0. 
    #export TRAEFIK_BASIC_AUTH_MIDDLEWARE=traefik.http.routers.api.middlewares=myAuth
fi

if echo "$DNS_PROVIDER" | grep -i "duckdns" > /dev/null; then 
    export INGRESS_DNS_TOKEN_ENV_NAME=DUCKDNS_TOKEN
    export TRAEFIK_LETS_ENCRYPT_CHALLENGE="--acme.dnsChallenge.provider=duckdns "
    export SECRETS_TO_IGNORE=ingress_dns_user,$SECRETS_TO_IGNORE
    export TRAEFIK_DOMAINS="--acme.domains=\"*.${DOMAIN},${DOMAIN}\" " \
    export SECRETS_TO_IGNORE

elif echo "$DNS_PROVIDER" | grep -i "cloudflare" > /dev/null; then
    #export DNS_USERNAME=tms@spencerslab.com
    export INGRESS_DNS_USER_ENV_NAME=CLOUDFLARE_EMAIL
    export INGRESS_DNS_TOKEN_ENV_NAME=CLOUDFLARE_API_KEY
    export TRAEFIK_LETS_ENCRYPT_CHALLENGE="--acme.dnsChallenge.provider=cloudflare "
    export TRAEFIK_DOMAINS="--acme.domains=\"*.${DOMAIN},${DOMAIN}\" " \

#elif echo "$DNS_PROVIDER" | grep -i ""; then135.181.110.238
#    echo ""

fi