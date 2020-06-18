FROM php:7.0.8-fpm-alpine

RUN apk add --no-cache --update \
        libmcrypt \
        libmcrypt-dev \
    && docker-php-ext-install \
        mysqli \
        opcache \
        intl \
        sockets \
        mcrypt \
    && rm -rf /tmp/* /var/cache/apk/* \
    && echo "=============================================" \
    && php -m

COPY ./config/dbadmin.conf /nginx/enabled/dbadmin.conf
COPY ./config/intech.conf/nginx/enabled/intech.conf
COPY ./config/php7-ext.conf /nginx/enabled/php7-ext.conf
COPY ./config/php7.conf /nginx/enabled/php7.conf

COPY ./config/php7.0.8-fpm-ext.conf /nginx/snippets/php7.0.8-fpm-ext.conf
COPY ./config/php7.0.8-fpm.conf /nginx/snippets/php7.0.8-fpm.conf
COPY ./config/snippet-php-fastcgi.conf /nginx/snippets/snippet-php-fastcgi.conf
COPY ./config/snippet-server-location-upstream.conf /nginx/snippets/snippet-server-location-upstream.conf

RUN mkdir /vhosts/intech
RUN mkdir /vhosts/intech/httpdocs
RUN mkdir /vhosts/intech/subdomains
COPY ./config/index.php /vhosts/intech/httpdocs/index.php
