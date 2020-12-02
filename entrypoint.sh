#!/usr/bin/env sh
# Most of this file comes from https://medium.com/@basi/docker-environment-variables-expanded-from-secrets-8fa70617b3bc 
# Thanks Basilio Vera, Rubén Norte, and Jose Manuel Cardona! 

: ${ENV_SECRETS_DIR:=/run/secrets}

env_secret_debug()
{
    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\033[1m$@\033[0m"
    fi
}

# usage: env_secret_expand VAR
#    ie: env_secret_expand 'XYZ_DB_PASSWORD'
# (will check for "$XYZ_DB_PASSWORD" variable value for a placeholder that defines the
#  name of the docker secret to use instead of the original value. For example:
# XYZ_DB_PASSWORD={{DOCKER-SECRET:my-db.secret}}
env_secret_expand() {
    var="$1"
    eval val=\$$var
    if secret_name=$(expr match "$val" "{{DOCKER-SECRET:\([^}]\+\)}}$"); then
        secret="${ENV_SECRETS_DIR}/${secret_name}"
        env_secret_debug "Secret file for $var: $secret"
        if [ -f "$secret" ]; then
            val=$(cat "${secret}")
            export "$var"="$val"
            env_secret_debug "Expanded variable: $var=$val"
        else
            env_secret_debug "Secret file does not exist! $secret"
        fi
    fi
}

env_secrets_expand() {
    for env_var in $(printenv | cut -f1 -d"=")
    do
        env_secret_expand $env_var
    done

    if [ ! -z "$ENV_SECRETS_DEBUG" ]; then
        echo -e "\n\033[1mExpanded environment variables\033[0m"
        printenv
    fi
}
env_secrets_expand


HASHED_PASSWORD=$(openssl passwd -apr1 $(cat /run/secrets/admin_password))
echo "${ADMIN_USER}:${HASHED_PASSWORD}" > /etc/traefik/usersfile

#exec "$@"
/entrypoint.sh --docker \
      --docker.swarmmode \
      --docker.watch \
      --docker.exposedbydefault=false \
      --constraints=tag==ingress \
      --entrypoints='Name:http Address::80' \
      --entrypoints='Name:https Address::443 TLS' \
      --defaultEntryPoints='http,https' \
      --acme \
      --acme.email=${EMAIL?Variable EMAIL not set} \
      --acme.storage=/etc/traefik/acme/acme.json \
      --acme.entryPoint=https \
      ${TRAEFIK_DOMAINS} \
      ${TRAEFIK_LETS_ENCRYPT_CHALLENGE} \
      ${TRAEFIK_ACME_CASERVER} \
      --acme.onhostrule=true \
      --acme.acmelogging=true \
      --logLevel=INFO \
      --accessLog \
      --api

## For Traefik 2.0
## Could use: --constraints=tag==ingress \
#/entrypoint.sh --providers.docker=true \
#    --providers.docker.swarmMode=true \
#    --providers.docker.watch \
#    --providers.docker.exposedbydefault=false \
#    --entryPoints.web.address=":80" \
#    --entryPoints.web-secure.address=":443" \
#    --entryPoints.mqtt.address=":1883" \
#    --entryPoints.mqtt-secure.address=":8883" \
#    --certificatesResolvers.lets-encrypt.acme.email="traefik.${STACK_NAME}@${DOMAIN}" \
#    --certificatesResolvers.lets-encrypt.acme.httpChallenge.entryPoint="web" \
#    --certificatesResolvers.lets-encrypt.acme.storage="/etc/traefik/acme/acme.json" \
#    ${TRAEFIK_LETS_ENCRYPT_CHALLENGE} \
#    ${TRAEFIK_ACME_CASERVER} \
#    --log.level="INFO" \
#    --accessLog \
#    --api
