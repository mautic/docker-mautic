Docker Mautic Image
===================
<img src="https://www.mautic.org/media/images/github_readme.png" />

# License

Mautic is distributed under the GPL v3 license. Full details of the license can be found in the [Mautic GitHub repository](https://github.com/mautic/mautic/blob/staging/LICENSE.txt).

# How to use this image

You can access and customize Docker Mautic from [Official Docker Hub image](https://hub.docker.com/r/mautic/mautic/).

# Pulling image from Docker Hub

If you want yo pull the latest stable image from DockerHub:

	docker pull mautic/mautic:latest

There are also another images that fit your needs:

| Tag | PHP | Web Server | Compatibility |
|-----|:-----:|:------------:|:---------------:|
| latest | 7.1.23 | Apache | <= 2.15.0 |
| apache | 7.1.23 | Apache | <= 2.15.0 |
| nginx | 7.1.23 | Nginx | <= 2.15.0 |
| beta-apache | 7.2.12 | Apache | >= 2.15.0 |
| beta-fpm | 7.2.12 | Nginx | >= 2.15.0 |

* You can use the beta images to test latest beta releases of Mautic with current PHP version.

# Running Basic Container

	docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw mysql &
	docker run --name some-mautic --link some-mysql:mysql mautic/mautic

## Customizing Mautic Container

The following environment variables are also honored for configuring your Mautic instance:

### Database Config
-	`-e MAUTIC_DB_HOST=...` (defaults to the IP and port of the linked `mysql` container)
-	`-e MAUTIC_DB_USER=...` (defaults to "root")
-	`-e MAUTIC_DB_PASSWORD=...` (defaults to the value of the `MYSQL_ROOT_PASSWORD` environment variable from the linked `mysql` container)
-	`-e MAUTIC_DB_NAME=...` (defaults to "mautic")
-	`-e MAUTIC_DB_TABLE_PREFIX=...` (defaults to empty) Add prefix do Mautic Tables. Very useful when migrate existing databases from another server to docker.

If you'd like to use an external database instead of a linked `mysql` container, specify the hostname and port with `MAUTIC_DB_HOST` along with the password in `MAUTIC_DB_PASSWORD` and the username in `MAUTIC_DB_USER` (if it is something other than `root`):

	docker run --name some-mautic -e MAUTIC_DB_HOST=10.1.2.3:3306 \
	    -e MAUTIC_DB_USER=... -e MAUTIC_DB_PASSWORD=... -d mautic/mautic

If the `MAUTIC_DB_NAME` specified does not already exist on the given MySQL server, it will be created automatically upon startup of the `mautic` container, provided that the `MAUTIC_DB_USER` specified has the necessary permissions to create it.

### Enable / Disable Crons
-	`-e MAUTIC_RUN_CRON_JOBS=...` (defaults to true - enabled) If set to true runs mautic cron jobs using included cron daemon
-	`-e MAUTIC_TRUSTED_PROXIES=...` (defaults to empty) If set to a list of comma separated CIDR network addresses it sets those addreses as trusted proxies. See [documentation](http://symfony.com/doc/current/request/load_balancer_reverse_proxy.html)
-	`-e MAUTIC_CRON_HUBSPOT=...` (defaults to empty) Enables mautic crons for Hubspot CRM integration
-	`-e MAUTIC_CRON_SALESFORCE=...` (defaults to empty) Enables mautic crons for Salesforce integration
-	`-e MAUTIC_CRON_PIPEDRIVE=...` (defaults to empty) Enables mautic crons for Pipedrive CRM integration
-	`-e MAUTIC_CRON_ZOHO=...` (defaults to empty) Enables mautic crons for Zoho CRM integration
-	`-e MAUTIC_CRON_SUGARCRM=...` (defaults to empty) Enables mautic crons for SugarCRM integration
-	`-e MAUTIC_CRON_DYNAMICS=...` (defaults to empty) Enables mautic crons for Dynamics CRM integration

### Enable / Disable Features
-	`-e MAUTIC_TESTER=...` (defaults to empty) Enables Mautic Github Pull Tester  [documentation](https://github.com/mautic/mautic-tester)

## Accesing the Instance
If you'd like to be able to access the instance from the host without the container's IP, standard port mappings can be used:

	docker run --name some-mautic --link some-mysql:mysql -p 8080:80 -d mautic

Then, access it via `http://localhost:8080` or `http://host-ip:8080` in a browser.


## ... via [`docker-compose`](https://github.com/docker/compose)

Example `docker-compose.yml` for `mautic`:

	mautic:
	  image: mautic/mautic
	  links:
	    - mauticdb:mysql
	  ports:
	    - 8080:80

	mauticdb:
	  image: mysql:5.6
	  environment:
	    MYSQL_ROOT_PASSWORD: example

Run `docker-compose up`, wait for it to initialize completely, and visit `http://localhost:8080` or `http://host-ip:8080`.

# Supported Docker versions

This image is officially supported on Docker version 1.7.1.

Support for older versions (down to 1.0) is provided on a best-effort basis.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/mautic/docker-mautic/issues).

You can also reach the Mautic community through its [online forums](https://www.mautic.org/community/) or the [Mautic Slack channel](https://www.mautic.org/slack/).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/mautic/docker-mautic/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
