FROM dunglas/frankenphp:latest-php8.2@sha256:96c4c874417d1acd2553120bd106746d2224c2ef8b194a03ea9755eff80f4e2b

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN install-php-extensions \
    bcmath \
    exif \
    gd \
    intl \
    mysqli \
    zip \
    imagick \
    opcache

COPY --from=wordpress@sha256:c714e59f58fc7e5f65441a8b4de57ae7c0cfe97e676c937ada8a86eba5d42bae /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d/
COPY --from=wordpress@sha256:c714e59f58fc7e5f65441a8b4de57ae7c0cfe97e676c937ada8a86eba5d42bae /usr/local/bin/docker-entrypoint.sh /usr/local/bin/
COPY --from=wordpress@sha256:c714e59f58fc7e5f65441a8b4de57ae7c0cfe97e676c937ada8a86eba5d42bae --chown=root:root /usr/src/wordpress /usr/src/wordpress

WORKDIR /var/www/html
VOLUME /var/www/html

ARG USER=www-data
RUN chown -R ${USER}:${USER} /data/caddy && chown -R ${USER}:${USER} /config/caddy

RUN sed -i \
    -e 's/\[ "$1" = '\''php-fpm'\'' \]/\[\[ "$1" == frankenphp* \]\]/g' \
    -e 's/php-fpm/frankenphp/g' \
    /usr/local/bin/docker-entrypoint.sh

RUN sed -i \
    -e 's#root \* public/#root \* /var/www/html/#g' \
    /etc/caddy/Caddyfile

USER ${USER}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
