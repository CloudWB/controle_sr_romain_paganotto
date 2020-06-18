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

RUN mv /config/dbadmin.conf /nginx/enabled/
RUN mv /config/intech.conf/nginx/enabled/
RUN mv /config/php7-ext.conf /nginx/enabled/
RUN mv /config/php7.conf /nginx/enabled/

RUN mv /config/php7.0.8-fpm-ext.conf /nginx/snippets/
RUN mv /config/php7.0.8-fpm.conf /nginx/snippets/
RUN mv /config/snippet-php-fastcgi.conf /nginx/snippets/
RUN mv /config/snippet-server-location-upstream.conf /nginx/snippets/

RUN mkdir /vhosts/intech
RUN mkdir /vhosts/intech/httpdocs
RUN mkdir /vhosts/intech/subdomains
RUN mv /config/index.php /vhosts/intech/httpdocs/
