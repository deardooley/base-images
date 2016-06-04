#!/bin/bash

set +e

sed -i 's#%HOSTNAME%#'$HOSTNAME'#g' /etc/apache2/httpd.conf
sed -i 's#%HOSTNAME%#'$HOSTNAME'#g' /etc/apache2/conf.d/ssl.conf

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

# Updated wordpress mysql config to match environment settings
if [[ -z "$MYSQL_HOST" ]]; then
  MYSQL_HOST=mysql
fi

if [[ -n "$MYSQL_PORT_3306_TCP_PORT" ]]; then
  MYSQL_PORT=3306
elif [[ -z "$MYSQL_PORT" ]]; then
  MYSQL_PORT=3306
fi

if [[ -n "$MYSQL_ENV_MYSQL_USER" ]]; then
  MYSQL_USERNAME=$MYSQL_ENV_MYSQL_USER
elif [[ -z "$MYSQL_USERNAME" ]]; then
  MYSQL_USERNAME=wordpress
fi

if [[ -n "$MYSQL_ENV_MYSQL_PASSWORD" ]]; then
  MYSQL_PASSWORD=$MYSQL_ENV_MYSQL_PASSWORD
elif [[ -z "$MYSQL_PASSWORD" ]]; then
  MYSQL_PASSWORD=password
fi

if [[ -n "$MYSQL_ENV_MYSQL_DATABASE" ]]; then
  MYSQL_DATABASE=$MYSQL_ENV_MYSQL_DATABASE
elif [[ -z "$MYSQL_DATABASE" ]]; then
  MYSQL_DATABASE=wordpress
fi

sed -i "s/%%DB_NAME%%/$MYSQL_DATABASE/g" /var/www/html/wp-config.php
sed -i "s/%%DB_USER%%/$MYSQL_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/%%DB_PASS%%/$MYSQL_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/%%DB_HOST%%/$MYSQL_HOST/g" /var/www/html/wp-config.php

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

if [[ -n "${INSTALL_DB}" ]]; then

  [[ ( -z "${ADMIN_USER}" ) ]] && ADMIN_USER=admin
  [[ ( -z "${ADMIN_PASSWORD}" ) ]] && ADMIN_PASSWORD=admin
  [[ ( -z "${ADMIN_EMAIL}" ) ]] && ADMIN_EMAIL="admin@example.com"
  [[ ( -z "${SITE_TITLE}" ) ]] && SITE_TITLE="Another Wordpress Blog"
  [[ ( -z "${SITE_URL}" ) ]] && SITE_URL=$HOSTNAME

  wp core install --url="${SITE_URL}"  --title="${SITE_TITLE}" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}"
fi

# update wordpress behavior set in the environment
if [[ -n "$DISALLOW_FILE_EDIT" ]]; then
  if (( ( "$DISALLOW_FILE_EDIT" == "false" ) || ( "$DISALLOW_FILE_EDIT" == "0" ) )); then
    sed -i "s#^define('DISALLOW_FILE_EDIT#//define('DISALLOW_FILE_EDIT#" /var/www/html/wp-config.php
  fi
fi

if [[ -n "$FORCE_SSL_ADMIN" ]]; then
  if (( ("$FORCE_SSL_ADMIN" == "false" ) || ( "$FORCE_SSL_ADMIN" == "0" ) )); then
    sed -i "s#^define('FORCE_SSL_ADMIN#//define('FORCE_SSL_ADMIN#" /var/www/html/wp-config.php
  fi
fi

if [[ -n "$TABLE_PREFIX" ]]; then
  sed -i "s#'wp_'#'"$TABLE_PREFIX"'#" /var/www/html/wp-config.php
fi

# start ntpd because clock skew is astoundingly real
ntpd -d -p pool.ntp.org &

# finally, run the command passed into the container
exec "$@"
