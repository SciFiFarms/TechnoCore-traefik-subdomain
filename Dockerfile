FROM traefik:v1.7.12-alpine

RUN apk add --no-cache openssl

## Set up the CMD as well as the pre and post hooks.
COPY go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exitpoint.sh /usr/bin/exitpoint.sh

ENTRYPOINT ["go-init", "-post", "/usr/bin/exitpoint.sh"]
CMD ["-main", "/usr/bin/entrypoint.sh"]
