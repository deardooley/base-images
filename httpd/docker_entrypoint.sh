#!/bin/bash

# Dynamically set document root at container startup
if [[ -z "$DOCUMENT_ROOT" ]]; then
  export DOCUMENT_ROOT=/var/www/html
fi

sed -i 's#%DOCUMENT_ROOT%#'$DOCUMENT_ROOT'#g' /etc/apache2/httpd.conf
sed -i 's#%DOCUMENT_ROOT%#'$DOCUMENT_ROOT'#g' /etc/apache2/conf.d/ssl.conf

# sed -i 's#%HOSTNAME%#'$HOSTNAME'#g' /etc/apache2/httpd.conf
# sed -i 's#%HOSTNAME%#'$HOSTNAME'#g' /etc/apache2/conf.d/ssl.conf

# Configure SSL as needed, defaulting to the self-signed cert unless otherwise specified.
if [[ -n "$SSL_CERT" ]]; then
  sed -i 's#^SSLCertificateFile .*#SSLCertificateFile '$SSL_CERT'#g' /etc/apache2/conf.d/ssl.conf
fi

if [[ -n "$SSL_KEY" ]]; then
  sed -i 's#^SSLCertificateKeyFile .*#SSLCertificateKeyFile '$SSL_KEY'#g' /etc/apache2/conf.d/ssl.conf
fi

if [[ -n "$SSL_CA_CHAIN" ]]; then
  sed -i 's#^\#SSLCertificateChainFile .*#SSLCertificateChainFile '$SSL_CA_CHAIN'#g' /etc/apache2/conf.d/ssl.conf
fi

if [[ -n "$SSL_CA_CERT" ]]; then
  sed -i 's#^\#SSLCACertificateFile .*#SSLCACertificateFile '$SSL_CA_CERT'#g' /etc/apache2/conf.d/ssl.conf
fi

# start ntpd because clock skew is astoundingly real
ntpd -d -p pool.ntp.org

# finally, run the command passed into the container
exec "$@"
