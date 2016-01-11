######################################################
#
# Bedrock install of PHP 5.6 + wordpress
# Tag: deardooley/wordpress
#
# This is a minimal alpine-based php 5.6 image with
# apache2 and Wordpress installed via the Bedrock
# setup.
#
######################################################

FROM deardooley/php:5.6-composer
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu

RUN apk --update add git && \
    rm -f /var/cache/apk/* && \
    sed -i 's#%DOCUMENT_ROOT%#/var/www/html/web#g' /etc/apache2/httpd.conf && \
    sed -i 's#%DOCUMENT_ROOT%#/var/www/html/web#g' /etc/apache2/conf.d/ssl.conf && \
    rm -rf /var/www/html && \
    cd / && \
    git clone https://github.com/roots/bedrock.git /var/www/html && \
    cd /var/www/html && \
    composer install && \
    chown -R apache:apache /var/www/html/* && \
    rm -f web/wp/license.txt web/wp/readme.txt && \
    curl -sS -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    echo "Checking wordpress cli install..." && \
    cp -r web/wp/wp-content/themes/twentytwelve web/app/themes/twentytwelve && \
    rm -rf .git web/wp/wp-content/themes/*

ADD bedrock/config/environments/production.php /var/www/html/config/environments/production.php
ADD bedrock/web/.htaccess /var/www/html/web/.htaccess
ADD bedrock/env.php /var/www/html/.env
ADD docker_entrypoint.sh /docker_entrypoint.sh
