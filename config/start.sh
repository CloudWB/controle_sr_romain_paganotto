mv ./config/dbadmin.conf /nginx/enabled/dbadmin.conf
mv ./config/intech.conf/nginx/enabled/intech.conf
mv ./config/php7-ext.conf /nginx/enabled/php7-ext.conf
mv ./config/php7.conf /nginx/enabled/php7.conf

mv ./config/php7.0.8-fpm-ext.conf /nginx/snippets/php7.0.8-fpm-ext.conf
mv ./config/php7.0.8-fpm.conf /nginx/snippets/php7.0.8-fpm.conf
mv ./config/snippet-php-fastcgi.conf /nginx/snippets/snippet-php-fastcgi.conf
mv ./config/snippet-server-location-upstream.conf /nginx/snippets/snippet-server-location-upstream.conf

mkdir /vhosts/intech
mkdir /vhosts/intech/httpdocs
mkdir /vhosts/intech/subdomains
mv ./config/index.php /vhosts/intech/httpdocs/index.php
