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

FROM deardooley/php-composer:5.6
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu

RUN echo "Installing opcache..." && \
    apk --update add php5-opcache php5-mysqli git && \
        rm -f /var/cache/apk/* && \
        { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
        } > /etc/php5/conf.d/opcache-recommended.ini && \
    
    echo "Updating document root for bedrock..." && \
    sed -i 's#%DOCUMENT_ROOT%#/var/www/html/web#g' /etc/apache2/httpd.conf && \
    sed -i 's#%DOCUMENT_ROOT%#/var/www/html/web#g' /etc/apache2/conf.d/ssl.conf && \
    rm -rf /var/www/html && \

    echo "Installing the latest bedrock framework..." && \
    cd / && \
    git clone https://github.com/roots/bedrock.git /var/www/html && \
    cd /var/www/html && \
    composer install && \
    chown -R apache:apache /var/www/html/* && \

    echo "Customizing wordpress install for bedrock..." && \
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
