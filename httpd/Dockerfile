######################################################
#
# Apache 2.4 Base Image
# Tag: deardooley/apache:alpine
#
# Minimal Apache 2.4 image with CORS, rewrite, and proxy
# support. Default unified logging to standard out.
#
######################################################

FROM alpine:3.2
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu

ADD tcp/limits.conf /etc/security/limits.conf
ADD tcp/sysctl.conf /etc/sysctl.conf

RUN /usr/sbin/deluser apache && \
    addgroup -g 50 -S apache && \
    adduser -u 1000 -g apache -G apache -S apache && \
    apk --update add apache2-ssl apache2-proxy vim gzip tzdata bash && \
    rm -f /var/cache/apk/* && \
    echo "Setting system timezone to America/Chicago..." && \
    ln -snf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    echo "Setting up ntpd..." && \
    echo $(setup-ntp -c busybox  2>&1) && \
    ntpd -d -p pool.ntp.org && \
    mv /var/www/localhost/htdocs /var/www/html && \
    chown -R apache:apache /var/www/html && \
    echo "Setting document root to DOCUMENT_ROOT..." && \
    sed -i 's#/var/www/localhost/htdocs#%DOCUMENT_ROOT%#g' /etc/apache2/httpd.conf && \
    sed -i 's#LogLevel warn#LogLevel info#g' /etc/apache2/httpd.conf && \
    sed -i 's#^ErrorLog logs/error.log#ErrorLog /proc/self/fd/2#g' /etc/apache2/httpd.conf && \
    sed -i 's#^CustomLog logs/access.log combined#CustomLog /proc/self/fd/1 combined#g' /etc/apache2/httpd.conf && \
    sed -i 's#^SSLMutex .*#Mutex sysvsem default#g' /etc/apache2/conf.d/ssl.conf && \
    sed -i 's#^ErrorLog logs/ssl_error.log#ErrorLog /proc/self/fd/2#g' /etc/apache2/conf.d/ssl.conf && \
    sed -i 's#^TransferLog logs/ssl_access.log#TransferLog /proc/self/fd/1#g' /etc/apache2/conf.d/ssl.conf && \
    sed -i 's#^CustomLog logs/ssl_request.log#CustomLog /proc/self/fd/1#g' /etc/apache2/conf.d/ssl.conf && \
    sed -i 's#LogLevel warn#LogLevel info#g' /etc/apache2/conf.d/ssl.conf

ADD docker_entrypoint.sh /docker_entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/docker_entrypoint.sh"]

CMD ["/usr/sbin/apachectl", "-DFOREGROUND"]
