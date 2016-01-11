#!/bin/bash

# Dynamically set document root at container startup
if [[ -z "$DOCUMENT_ROOT" ]]; then
  DOCUMENT_ROOT=/var/www/html
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

# Configure container smtp email as needed
if [[ -z "${SMTP_HUB}" ]]; then
  SMTP_HUB='localhost'
fi
sed -ri -e "s/%%SMTP_HUB%%/$SMTP_HUB/" /etc/ssmtp/ssmtp.conf

if [[ -z "${SMTP_USER}" ]]; then
  SMTP_USER=''
fi
sed -ri -e "s/%%SMTP_USER%%/$SMTP_USER/" /etc/ssmtp/ssmtp.conf

if [[ -z "${SMTP_TLS}" ]]; then
  SMTP_TLS='NO'
else
  SMTP_TLS='YES'
fi
sed -ri -e "s/UseSTARTTLS=$SMTP_TLS/UseSTARTTLS=NO/" /etc/ssmtp/ssmtp.conf

if [[ -z "${SMTP_PASSWORD}" ]]; then
  SMTP_PASSWORD=''
fi
sed -ri -e "s/%%SMTP_PASSWORD%%/$SMTP_PASSWORD/" /etc/ssmtp/ssmtp.conf

if [[ -z "${SMTP_FROM_ADDRESS}" ]]; then
  echo "root:$SMTP_FROM_ADDRESS:$SMTP_HUB" >> /etc/ssmtp/revaliases
  echo "apache:$SMTP_FROM_ADDRESS:$SMTP_HUB" >> /etc/ssmtp/revaliases
  echo "admin:$SMTP_FROM_ADDRESS:$SMTP_HUB" >> /etc/ssmtp/revaliases
fi

# start ntpd because clock skew is astoundingly real
ntpd -d -p pool.ntp.org

# finally, run the command passed into the container
exec "$@"
