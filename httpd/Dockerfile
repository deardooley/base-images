######################################################
#
# Apache 2.4 Base Image
# Tag: deardooley/apache:alpine
#
# Minimal Apache 2.4 image with CORS, rewrite, and proxy
# support. Default unified logging to standard out.
#
######################################################

FROM alpine:3.3
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu

ADD tcp/limits.conf /etc/security/limits.conf
ADD tcp/sysctl.conf /etc/sysctl.conf

RUN apk --update add apache2-proxy apache2-proxy-html vim gzip tzdata bash curl && \
    rm -f /var/cache/apk/* && \
    /usr/sbin/deluser apache && \

    addgroup -g 50 -S apache && \
    adduser -u 1000 -g apache -G apache -S apache && \
    mkdir /run/apache2 && \
    chown -R apache:root /run/apache2 && \
    
    # Set up system timezone and sync
    echo "Setting system timezone to America/Chicago..." && \
    ln -snf /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    ntpd -d -p pool.ntp.org && \

    echo "Updating default apache DocumentRoot..." && \
    mkdir /var/www/html && \
    chown -R apache:apache /var/www/html && \
    # fix bug in proxy.conf and proxy-html.conf in stock apache install
    sed -i 's/^    AllowOverride None/    AllowOverride All/' /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule slotmem_shm_module/LoadModule slotmem_shm_module/'  /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule socache_shmcb_module/LoadModule socache_shmcb_module/'  /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule rewrite_module/LoadModule rewrite_module/'  /etc/apache2/httpd.conf && \
    sed -i 's#/usr/lib/libxml2.so$#/usr/lib/libxml2.so.2#' /etc/apache2/conf.d/proxy-html.conf && \
    sed -i 's#/usr/lib/libxml2.so$#/usr/lib/libxml2.so.2#' /etc/apache2/conf.d/proxy.conf && \
    sed -i 's#/var/www/localhost/htdocs#%DOCUMENT_ROOT%#g' /etc/apache2/httpd.conf && \
#    sed -i 's#^SSLMutex .*#Mutex sysvsem default#g' /etc/apache2/conf.d/ssl.conf && \

    # update logging to write
    sed -i 's#/var/www/localhost/htdocs#%DOCUMENT_ROOT%#g' /etc/apache2/httpd.conf && \
    #sed -i 's#LogLevel warn#LogLevel info#g' /etc/apache2/httpd.conf && \
    sed -i 's#^ErrorLog logs/error.log#ErrorLog /proc/self/fd/2#g' /etc/apache2/httpd.conf && \
    sed -i 's#^CustomLog logs/access.log combined#CustomLog /proc/self/fd/1 combined#g' /etc/apache2/httpd.conf 
#    sed -i 's#^SSLMutex .*#Mutex sysvsem default#g' /etc/apache2/conf.d/ssl.conf && \
#   sed -i 's#^ErrorLog logs/ssl_error.log#ErrorLog /proc/self/fd/2#g' /etc/apache2/conf.d/ssl.conf && \
#    sed -i 's#^TransferLog logs/ssl_access.log#TransferLog /proc/self/fd/1#g' /etc/apache2/conf.d/ssl.conf && \
#    sed -i 's#^CustomLog logs/ssl_request.log#CustomLog /proc/self/fd/1#g' /etc/apache2/conf.d/ssl.conf && \
    #sed -i 's#LogLevel warn#LogLevel info#g' /etc/apache2/conf.d/ssl.conf && \

#    sed -i 's#^SSLProtocol .*#SSLProtocol all -SSLv2 -SSLv3#g' /etc/apache2/conf.d/ssl.conf

ADD docker_entrypoint.sh /docker_entrypoint.sh

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/docker_entrypoint.sh"]

CMD ["httpd", "-DFOREGROUND"]
