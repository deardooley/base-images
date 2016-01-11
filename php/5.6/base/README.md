## PHP Base Image

This is a minimal php 5.5 base image with apache2 configured. It has friendly settings for form handling and supports both access and error logging to stdout.

## Extending this image

This image can be used as a standard web server for most PHP apps. It is sufficient to add a .htaccess file to
the server root to set up redirects, etc. If you need composer, see the `deardooley/php-composer` image.

### Developing with this image

If you are developing with this image, mount your code into the `/var/www/html` directory in the container. Your local changes will be reflected instantly when you refresh your page.

```
docker run -h docker.example.com
           -p 80:80 \
           --name apache \
           -v `pwd`:/var/www/html \
           --link mysql:mysql
           -e DOCUMENT_ROOT=/var/www/html
           deardooley/php:5.5
```

Alternatively, you can specify a different web root if needed by your application. For example, if you had a Laravel project where the project `composer.json` file was located at `/usr/local/src/laravel/composer.json`, the following would start the container with the proper web root for the project.

```
docker run -h docker.example.com
           -p 80:80 \
           --name apache \
           -v /usr/local/src/laravel:/var/www \
           --link mysql:mysql
           -e DOCUMENT_ROOT=/var/www/public
           deardooley/php:5.5
```

### Running in production

When running in production, both the access and error logs will stream to standard out so they can be access via the Docker logs facility by default.

```
docker run -h docker.example.com \
           -p 80:80 \
           -p 443:443 \
           --name apache \
           deardooley/php:5.5

docker logs apache
```

### SSL Support

To add ssl support, volume mount your ssl cert, key, ca cert file, and ca chain file as needed. In the following example, a folder containing the necessary files is volume mounted to /ssl in the container.

```
docker run -h docker.example.com \
           -p 80:80 \
           -p 443:443 \
           --name apache \
           -v `pwd`/ssl:/ssl:ro \
           -e SSL_CERT=/ssl/docker_example_com_cert.cer \
           -e SSL_KEY=/ssl/docker.example.com.key \
           -e SSL_CA_CERT=/ssl/docker_example_com.cer \
           deardooley/php:5.5
```

### Email Server

There is no embedded mail server in this image. In order to use the PHP `mail()` command, you will need to configure a SMTP relay server through your environment.

Variable | Description
----------|----------|------------
| SMTP_HUB | Hostname and port of the SMTP relay server. ex. `"smtp.sendgrid.net:587"` |
| SMTP_USER | Account username used to authenticate to the SMTP relay |
| SMTP_PASSWORD | Account password used to authenticate to the SMTP relay |
| SMTP_FROM_ADDRESS | Email address used in the *from* field ex. `noreply@example.com` |
| SMTP_TLS | `1` if TLS should be used, `0` otherwise. Default is `1` |

```
docker run -h docker.example.com \
           -p 80:80 \
           -p 443:443 \
           --name apache \
           -v `pwd`/ssl:/ssl:ro \
           -e SMTP_HUB="smtp.sendgrid.net:587" \
           -e SMTP_USER=username \
           -e SMTP_PASSWORD=password \
           -e SMTP_FROM_ADDRESS="noreply@example.com" \
           -e SMTP_TLS=1 \
           -e SSL_CERT=/ssl/docker_example_com_cert.cer \
           -e SSL_KEY=/ssl/docker.example.com.key \
           -e SSL_CA_CERT=/ssl/docker_example_com.cer \
           deardooley/php:5.5
```
