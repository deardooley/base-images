######################################################
#
# PHP 5.6 Base Image
# Tag: deardooley/php:5.6
#
# This is a minimal alpine-based php 5.6 image with Apache 2.4.
#
######################################################

FROM deardooley/httpd:2.4
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu

RUN apk --update add curl zip php-apache2 php-cli php-json php-phar php-openssl php-mysql php-pdo php-zip php-ctype php-curl php-mysqli php-gd php-iconv php-zlib php-xml php-dom php-mcrypt php-pdo_mysql ssmtp && \
    rm -f /var/cache/apk/* && \
    echo "<?php phpinfo(); ?>" > /var/www/html/index.php && \
    chown -R apache:apache /var/www/html && \
    sed -ri -e 's/^(mailhub=).*/\1%%SMTP_HUB%%/' -e 's/^#(FromLineOverride)/\1/' /etc/ssmtp/ssmtp.conf && \
    echo "AuthUser=%%SMTP_USER%%" >> /etc/ssmtp/ssmtp.conf && \
    echo "AuthPass=%%SMTP_PASSWORD%%" >> /etc/ssmtp/ssmtp.conf && \
    echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf

ADD php/php.ini /etc/php/php.ini
