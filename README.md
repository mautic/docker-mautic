# Netresearch Mautic Container Image

<img src="Mautic_Logo_RGB_LB.png" style="width:100%;height:auto;" />

# License

Mautic is distributed under the GPL v3 license. Full details of the license can be found in the [Mautic GitHub repository](https://github.com/mautic/mautic/blob/staging/LICENSE.txt).

# How to use netresearch/docker-mautic

netresearch/docker-mautic provides a basic environment for Mautic to run correctly.

Docker images are always simple and functional by design, if you need to add specific features to your Mautic Setup just create a new image based on this image. You can access and customize netresearch/docker-mautic on https://github.com/netresearch/docker-mautic.

# Pulling netresearch/docker-mautic

If you want to pull the latest **stable** v3 image from netresearch/docker-mautic:

    docker pull ghcr.io/netresearch/mautic:3-apache
    docker pull ghcr.io/netresearch/mautic:3-fpm

If you want to pull the latest **stable** v2 image from netresearch/docker-mautic:

    docker pull ghcr.io/netresearch/mautic:2-apache
    docker pull ghcr.io/netresearch/mautic:2-fpm


# Running Basic Container

Setting up a Network to connect Mautic and DBMS:

    $ docker network create mauticnet

Setting up MariaDB 10.2+ (Percona or MySQL works as well):

    $ docker volume create mysql_data

    $ docker run --name database -d \
        --restart=unless-stopped \
        -e MYSQL_ROOT_PASSWORD=mypassword \
        -e MYSQL_DATABASE=mautic \
        -e MYSQL_USER=mautic \
        -e MYSQL_PASSWORD=mauticdbpass \
        -v mysql_data:/var/lib/mysql \
        --net=mauticnet \
        mariadb/mariadb:10.2 \
          --character-set-server=utf8mb4 \
          --collation-server=utf8mb4_general_ci

Setting Up Mautic:

    $ docker volume create mautic_data

    $ docker run --name mautic -d \
        --restart=unless-stopped \
        -e MAUTIC_DB_HOST=database \
        -e MAUTIC_DB_NAME=mautic \
        -e MAUTIC_DB_USER=mautic \
        -e MAUTIC_DB_PASSWORD=mauticdbpass \
        -e MAUTIC_RUN_CRON_JOBS=true \
        -p 8080:80 \
        --net=mauticnet \
        -v mautic_data:/var/www/html \
        ghcr.io/netresearch/mautic:3-apache

This will run a basic Mautic on http://localhost:8080.

# Configuration

The following environment variables are also honored for configuring your Mautic instance:

## Database Options

- `MAUTIC_DB_HOST=mysql` Database host name
- `MAUTIC_DB_USER=root` Databse user name
- `MAUTIC_DB_PASSWORD=` Database user password
- `MAUTIC_DB_NAME=mautic` Database name
- `MAUTIC_DB_TABLE_PREFIX=` Add prefix do Mautic tables. Very useful when migrate existing databases from another server to docker.

If you'd like to use an external database instead of a linked `mysql` container, specify the hostname and port with `MAUTIC_DB_HOST` along with the password in `MAUTIC_DB_PASSWORD` and the username in `MAUTIC_DB_USER` (if it is something other than `root`).

## Mautic Options

- `MAUTIC_RUN_CRON_JOBS=true` If set to true runs mautic cron jobs using included cron daemon
- `MAUTIC_TRUSTED_PROXIES=` If it's Mautic behind a reverse proxy you can set a list of comma-separated CIDR network addresses it sets those addresses as trusted proxies. You can use `["0.0.0.0/0"]` or See [documentation](http://symfony.com/doc/current/request/load_balancer_reverse_proxy.html)
- `MAUTIC_CRON_HUBSPOT=` Enables mautic crons for Hubspot CRM integration
- `MAUTIC_CRON_SALESFORCE=` Enables mautic crons for Salesforce integration
- `MAUTIC_CRON_PIPEDRIVE=` Enables mautic crons for Pipedrive CRM integration
- `MAUTIC_CRON_ZOHO=` Enables mautic crons for Zoho CRM integration
- `MAUTIC_CRON_SUGARCRM=` Enables mautic crons for SugarCRM integration
- `MAUTIC_CRON_DYNAMICS=` Enables mautic crons for Dynamics CRM integration

## PHP options

- `PHP_INI_DATE_TIMEZONE=UTC` Set PHP timezone
- `PHP_MEMORY_LIMIT=256M` Set PHP memory limit
- `PHP_MAX_UPLOAD=20M` Set PHP upload max file size
- `PHP_MAX_EXECUTION_TIME=300` Set PHP max execution time

# Persistent Data Volumes

On first run Mautic is unpacked at `/var/www/html`. You need to attach a volume on this path to persist data.

# Add SSL to your Mautic

If you change the _Site Address_ of _Mautic General Settings tab_ to HTTPS (behind a reverse proxy), you can use `0.0.0.0/0` as Trusted Proxies to avoid a redirect loop error. See [documentation](http://symfony.com/doc/current/request/load_balancer_reverse_proxy.html)

# ... via [`docker-compose`](https://github.com/docker/compose)

Example `docker-compose.yml` for `mautic` with SSL termination through nginx:

```yaml
version: "2"

services:
  mautic:
    restart: unless-stopped
    image: ghcr.io/netresearch/mautic:3-apache
    depends_on:
      - dbms
    environment:
      MAUTIC_DB_HOST: dbms
      MAUTIC_DB_USER: mautic
      MAUTIC_DB_PASSWORD: mauticdbpass
      MAUTIC_TRUSTED_PROXIES: '["0.0.0.0/0"]'
    volumes:
      - mautic-web:/var/www/html

  dbms:
    restart: unless-stopped
    image: mariadb:10.2
    environment:
      MYSQL_ROOT_PASSWORD: mysqlrootpassword
      MYSQL_DATABASE: mautic
      MYSQL_USER: mautic
      MYSQL_PASSWORD: mauticdbpass
    volumes:
      - database:/var/lib/mysql

  nginx:
    restart: unless-stopped
    image: nginx
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - sslcerts:/etc/ssl/private
    entrypoint:
      - "bash"
      - "-c"
    command: |
      "if [ ! -f /etc/ssl/private/mautic.crt ]; then
        echo 'ssl certificate missing, installing openssl to create a new one'
        apt-get update && apt-get install openssl -y
        openssl req -x509 -newkey rsa:2048 -sha256 -nodes -keyout /etc/ssl/private/mautic.key -out /etc/ssl/private/mautic.crt -subj '/CN=mautic.local' -days 3650
        echo 'Created new ssl certificate'
      fi
      exec nginx -g 'daemon off;'"

volumes:
  mautic-web:
  sslcerts:
  database:
```

Run `docker-compose up`, wait for it to initialize completely, and visit `https://localhost` or `https://host-ip`.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/netresearch/docker-mautic/issues).

You can also reach the Mautic community through its [online forums](https://www.mautic.org/community/) or the [Mautic Slack channel](https://www.mautic.org/slack/).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

# Building

## Mautic Versioning

The Dockerfile has two ENV where you can specify an version to be built into cotnainer image:

- `MAUTIC_VERSION`
- `MAUTIC_SHA1`

You can update this to latest version by running `./update.sh`
