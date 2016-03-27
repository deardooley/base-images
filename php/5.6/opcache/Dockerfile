######################################################
#
# PHP 5.6 Base Image
# Tag: deardooley/php:5.6-opcache
#
# This is a minimal alpine-based php 5.6 image with Apache 2.4.
#
######################################################

FROM deardooley/php:5.6-composer
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu

RUN apk --update add php-opcache && \
    rm -f /var/cache/apk/* && \
    { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /etc/php/conf.d/opcache-recommended.ini
