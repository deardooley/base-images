#!/bin/bash

set +e

# Update hostname in httpd.conf and ssl.conf files so we get a clean startup
sed -i 's#%HOSTNAME%#'$(hostname)'#g' /etc/apache2/httpd.conf
sed -i 's#%HOSTNAME%#'$(hostname)'#g' /etc/apache2/conf.d/ssl.conf

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
  [[ ( -z "${SITE_URL}" ) ]] && SITE_URL=$(hostname)

  wp core install --url="${SITE_URL}"  --title="${SITE_TITLE}" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}"
fi

# update wordpress behavior set in the environment
if [[ -n "$DISALLOW_FILE_EDIT" ]]; then
  if [[ "$DISALLOW_FILE_EDIT" == "false" ]] || [[ "$DISALLOW_FILE_EDIT" == "0" ]]; then
    sed -i "s#define('DISALLOW_FILE_EDIT',.*#define('DISALLOW_FILE_EDIT', false);#" /var/www/html/wp-config.php
  else
    sed -i "s#define('DISALLOW_FILE_EDIT',.*#define('DISALLOW_FILE_EDIT', true);#" /var/www/html/wp-config.php
  fi
fi

if [[ -n "$FORCE_SSL_ADMIN" ]]; then
  if [[ "$FORCE_SSL_ADMIN" == "false" ]] || [[ "$FORCE_SSL_ADMIN" == "0" ]]; then
    sed -i "s#define('FORCE_SSL_ADMIN',.*#define('FORCE_SSL_ADMIN', false);#" /var/www/html/wp-config.php
  else
    sed -i "s#define('FORCE_SSL_ADMIN',.*#define('FORCE_SSL_ADMIN', true);#" /var/www/html/wp-config.php
  fi
fi

if [[ -n "$WP_ACCESSIBLE_HOSTS" ]]; then
  sed -i "s#define('WP_ACCESSIBLE_HOSTS',.*#define('WP_ACCESSIBLE_HOSTS', '"$WP_ACCESSIBLE_HOSTS"');#" /var/www/html/wp-config.php
fi

if [[ -n "$WP_HTTP_BLOCK_EXTERNAL" ]]; then
  if [[ "$WP_HTTP_BLOCK_EXTERNAL" == "false" ]] || [[ "$WP_HTTP_BLOCK_EXTERNAL" == "0" ]]; then
    sed -i "s#define('WP_HTTP_BLOCK_EXTERNAL',.*#define('WP_HTTP_BLOCK_EXTERNAL', false);#" /var/www/html/wp-config.php
  else
    sed -i "s#define('WP_HTTP_BLOCK_EXTERNAL',.*#define('WP_HTTP_BLOCK_EXTERNAL', true);#" /var/www/html/wp-config.php
  fi
fi

if [[ -n "$DISABLE_WP_CRON" ]]; then
  if [[ "$DISABLE_WP_CRON" == "false" ]] || [[ "$DISABLE_WP_CRON" == "0" ]]; then
    sed -i "s#define('DISABLE_WP_CRON',.*#define('DISABLE_WP_CRON', false);#" /var/www/html/wp-config.php
  else
    sed -i "s#define('DISABLE_WP_CRON',.*#define('DISABLE_WP_CRON', true);#" /var/www/html/wp-config.php
  fi
fi

if [[ -z "$WP_REDIS_HOST" ]]; then
  WP_REDIS_HOST=redis
fi
sed -i "s#%WP_REDIS_HOST%#"$WP_REDIS_HOST"#" /var/www/html/wp-config.php

if [[ -z "$WP_REDIS_DATABASE" ]]; then
  WP_REDIS_DATABASE=22
fi
sed -i "s#%WP_REDIS_DATABASE%#"$WP_REDIS_DATABASE"#" /var/www/html/wp-config.php

if [[ -z "$WP_REDIS_PORT" ]]; then
  WP_REDIS_PORT=6379
fi
sed -i "s#%WP_REDIS_PORT%#"$WP_REDIS_PORT"#" /var/www/html/wp-config.php

if [[ -z "$WP_REDIS_PASSWORD" ]]; then
  WP_REDIS_PASSWORD=''
fi
sed -i "s#%WP_REDIS_PASSWORD%#"$WP_REDIS_PASSWORD"#" /var/www/html/wp-config.php

if [[ -n "$TABLE_PREFIX" ]]; then
  sed -i "s#'wp_'#'"$TABLE_PREFIX"'#" /var/www/html/wp-config.php
fi

# Parse user-supplied limits on upload sizes
if [[ -n "$UPLOAD_MAX_FILESIZE" ]]; then
  sed -i 's#upload_max_filesize .*#upload_max_filesize = '$UPLOAD_MAX_FILESIZE'#' /etc/php5/php.ini
fi

if [[ -n "$POST_MAX_SIZE" ]]; then
  sed -i 's#post_max_size .*#post_max_size = '$POST_MAX_SIZE'#' /etc/php5/php.ini
fi

# start ntpd because clock skew is astoundingly real
ntpd -d -p pool.ntp.org &

# finally, run the command passed into the container
exec "$@"
