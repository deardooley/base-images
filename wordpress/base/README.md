[![](https://badge.imagelayers.io/deardooley/wordpress:vanilla.svg)](https://imagelayers.io/?images=deardooley/wordpress:vanilla 'Get your own badge on imagelayers.io')

# Vanilla Wordpress

This is a minimal wordpress image built off apache2 and composer. The installation can be managed via the
installed [wp-cli](https://github.com/wp-cli/wp-cli/). This image is sufficient to run for development or behind a proxy for production. Both SSL is bundled by default along with forced https redirect for `/wp-admin/`.

## Developing with this image

If you are developing with this image, mount your local `/wp-content` folder into the `/var/www/html/wp-content` directory in the container. Your local changes will be reflected instantly when you refresh your page.

```
docker run -h docker.example.com
           -p 80:80 \
           --name wordpress \
           --link mysql:mysql
           -v `pwd`/wp-content:/var/www/html/wp-content \
           wordpress:vanilla
```

You may also update several wordpress settings to easier development environments. A list of supported parameters are listed in the following table.

Variable | Type | Description
----------|----------|----------
DB_PREFIX | string | The prefix to the tables in your database
FORCE_SSL_ADMIN | boolean | Whether to force SSL for all access to the wordpress admin area. default: true
DISALLOW_FILE_EDIT | boolean | Whether the wordpress admin area allows you to edit plugin and theme files. default: true

### WP-CLI
You may use the `wp-cli` in the standard way to import images, manage content, etc. A good article on using the `wp-cli` is available from [Smashing Magazine](https://www.smashingmagazine.com/2015/09/wordpress-management-with-wp-cli/).

### Extending this image

To extend this image, you should manually add your plugins, themes, etc into the `wp-content` directory. Do not add any sensitive information into the image. Your database connection, email relay, etc can all be specified via environment variables.

## Running in production

When running in production, both the access and error logs will stream to standard out so they can be access via the Docker logs facility by default.

### Backup and media

We recommend using a plugin to mirror your uploaded media to a commercial cloud storage provider and using an external task to back up your database. The `docker-compose.yml` file included with this repository has an example backup solution.

```
docker run -h docker.example.com \
           -p 80:80 \
           -p 443:443 \
           --name wordpress \
           --link mysql:db \
           deardooley/wordpress:vanilla
```

### WP-Cron and scheduled tasks

There is no unix cron daemon available in the container. In order to ensure your Wordpress cron tasks run on schedule, you should make use of an external cron solution. There are plenty of web-based cron services available. Alternatively, you can use the `deardooley/cron` Docker image to query your site. The `docker-compose.yml` file included with this repository has an example cron solution.  

### SSL support

To add custom ssl keys for your domain, volume mount your ssl cert, key, ca cert file, and ca chain file and specify the files using the environment variables described in the table below.

Variable | Description
----------|----------|------------
SSL_CERT | Your server SSL certificate
SSL_KEY | Your server SSL private key
SSL_CA_CERT | Your server CA certificate

In the following example, a folder containing the necessary files is volume mounted to `/ssl` in the container.

```
docker run -h docker.example.com \
           -p 80:80 \
           -p 443:443 \
           --name wordpress \
           --link mysql:db \
           -v `pwd`/ssl:/ssl:ro \
           -e SSL_CERT=/ssl/docker_example_com_cert.cer \
           -e SSL_KEY=/ssl/docker.example.com.key \
           -e SSL_CA_CERT=/ssl/docker_example_com.cer \
           deardooley/wordpress:vanilla
```

### Email configuration

There is no embedded mail server in this image. In order for Wordpress to send emails, you will need to install a mail plugin, such as [SendGrid](https://wordpress.org/plugins/sendgrid-email-delivery-simplified/) or configure a SMTP relay server through your environment. You can do this through the following environment variables.

Variable | Description
----------|----------|------------
SMTP_HUB | Hostname and port of the SMTP relay server. ex. `"smtp.sendgrid.net:587"`
SMTP_USER | Account username used to authenticate to the SMTP relay
SMTP_PASSWORD | Account password used to authenticate to the SMTP relay
SMTP_FROM_ADDRESS | Email address used in the ***from*** field ex. `noreply@example.com`
SMTP_TLS | `1` if TLS should be used, `0` otherwise. Default is `1`

An example command is shown below.

```
docker run -h docker.example.com \
           -p 80:80 \
           -p 443:443 \
           --name wordpress \
           --link mysql:db \
           -v `pwd`/ssl:/ssl:ro \
           -e SMTP_HUB="smtp.example.com:25" \
           -e SMTP_USER=username \
           -e SMTP_PASSWORD=password \
           -e SMTP_FROM_ADDRESS="noreply@example.com" \
           -e SMTP_TLS=1 \
           -e SSL_CERT=/ssl/docker_example_com_cert.cer \
           -e SSL_KEY=/ssl/docker.example.com.key \
           -e SSL_CA_CERT=/ssl/docker_example_com.cer \
           deardooley/wordpress:vanilla
```
