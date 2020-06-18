RUN cp dbadmin.conf /nginx/enabled/dbadmin.conf
RUN cp dbadmin.conf /nginx/enabled/intech.conf
RUN cp dbadmin.conf /nginx/enabled/php7-ext.conf
RUN cp dbadmin.conf /nginx/enabled/php7.conf

RUN cp dbadmin.conf /nginx/snippets/php7.0.8-fpm-ext.conf
RUN cp dbadmin.conf /nginx/snippets/php7.0.8-fpm.conf
RUN cp dbadmin.conf /nginx/snippets/snippet-php-fastcgi.conf
RUN cp dbadmin.conf /nginx/snippets/snippet-server-location-upstream.conf

RUN mkdir /vhosts/intech
RUN mkdir /vhosts/intech/httpdocs
RUN mkdir /vhosts/intech/subdomains
RUN cp index.php /vhosts/intech/httpdocs/index.php
