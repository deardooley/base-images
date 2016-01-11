######################################################
#
# PHP 5.6 + wordpress
# Tag: deardooley/wordpress
#
# This is a minimal alpine-based php 5.6 image with
# apache2 and composer installed.
#
######################################################

FROM deardooley/php-composer:5.6
MAINTAINER Rion Dooley <dooley@tacc.utexas.edu

RUN curl -sS -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    sed -i 's#%DOCUMENT_ROOT%#/var/www/html/web#g' /etc/apache2/httpd.conf && \
    sed -i 's#%DOCUMENT_ROOT%#/var/www/html/web#g' /etc/apache2/conf.d/ssl.conf && \
    echo "Checking wordpress cli install..." && \
    wp --info && \
    wp core download && \
    { \
      echo "define('WP_DEBUG', true);"; \
      echo "define('WP_DEBUG_DISPLAY', false );"; \
      echo "define('SAVEQUERIES', true);"; \
      echo "define('SCRIPT_DEBUG', true);"; \
      echo "define('DISALLOW_FILE_EDIT', true);"; \
      echo "define('FORCE_SSL_ADMIN', true);"; \
      echo "if (\$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') \$_SERVER['HTTPS']='on';"; \
      echo "\$sgenv = array('USERNAME','PASSWORD','API_KEY','SEND_METHOD','FROM_NAME','FROM_EMAIL','REPLY_TO','CATEGORIES','TEMPLATE');"; \
      echo "foreach(\$sgenv as \$sgvar) { "; \
      echo "  if (isset(\$_ENV['SENDGRID_'.\$sgvar])) {"; \
      echo "    define('SENDGRID_'.\$sgvar, \$_ENV['SENDGRID_'.\$sgvar]); "; \
      echo "  }"; \
      echo "}"; \
    } | wp core config --dbname='%%DB_NAME%%' --dbuser='%%DB_USER%%' --dbpass='%%DB_PASS%%' --dbhost='%%DB_HOST%%' --skip-check --extra-php && \
    chown -R apache:apache /var/www/html/*

ADD docker_entrypoint.sh /docker_entrypoint.sh
