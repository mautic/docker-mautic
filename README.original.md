# Mautic Docker image and examples

> [!NOTE]
> _This version refers to Docker images and examples for Mautic 5. If you would like information about older versions, see https://github.com/mautic/docker-mautic/tree/mautic4._

## Versions

all Mautic 5 Docker images follow the following naming stategy.

`<major.minor.patch>-<variant>`

There are some defaults if parts are omitted:

* `<minor.patch>` is the latest release patch version in the latest minor version.

some examples:

* `5-apache`: latest stable version of Mautic 5 of the `apache` variant
* `5.0-fpm`: latest version in the 5.0 minor release in the `fpm` variant 
* `5.0.3-apache`: specific point release of the `apache` variant

## Variants

The Docker images exist in 2 variants:

* `apache`: image based on the official `php:apache` images.
* `fpm`: image based on the official `php:fpm` images.

The latest supported Mautic PHP version is used the moment of generating of the image.

Each variant contains:

* the needed dependencies to run Mautic (e.g. PHP modules)
* the Mautic codebase installed via composer (see mautic/recommended-project)
* the needed files and configuration to run as a specific role

See the `examples` explanation below how you could use them.

## Roles

each image can be started in 3 modes:

* `mautic_web`: runs the Mautic webinterface
* `mautic_worker`: runs the worker processes to consume the messenger queues 
* `mautic_cron`: runs the defined cronjobs

This allows you to use different scaling strategies to run the workers or crons, without having to maintain separate images.  
The `mautic_cron` and `mautic_worker` require the codebase anyhow, as they execute console commands that need to bootstrap the full application.

## Examples

The `examples` folder contains examples of `docker-compose` setups that use the Docker images.  

> [!WARNING]
> The examples **require `docker compose` v2**.  
> Running the examples with the unsupported `docker-compose` v1 will result in a non-starting web container.  

> [!IMPORTANT]
> Please take into account the purpose of those examples:  
> it shows how it **could** be used, not how it **should** be used.  
> Do not use those examples in production without reviewing, understanding and configuring them.

* `basic`: standard example using the `apache` image with `doctrine` as async queue.
* `fpm-nginx`: example using the `fpm` image in combination with an `nginx` with `doctrine` as async queue.
* `rabbitmq-worker`: example using the `apache` image with `rabbitmq` as async queue.

## Building your own images

You can build your own images easily using the `docker build` command in the root of this directory:

```
docker build . -f apache/Dockerfile -t mautic/mautic:5-apache
docker build . -f fpm/Dockerfile -t mautic/mautic:5-fpm
```

## Persistent storage

The images by default foresee following volumes to persist data (not taking into account e.g. database or queueing data, as that's not part of these images).

 * `config`: the local config folder containing `local.php`, `parameters_local.php`, ...
 * `var/logs`: the folder with logs
 * `docroot/media`: the folder with uploaded and generated media files

## Configuration and customizing

### Configuration

The following environment variables can be used to configure how your setup should behave.
There are 2 files where those settings can be set:

* the `.env` file: 
  Should be used for all general variables for Mysql, PHP, ...
* the `.mautic_env` file:
  Should be used for all Mautic specific variables.

Those variables can also be set via the `environment` key on services defined in the `docker-compose.yml` file.

#### MySQL settings
 - `MYSQL_HOST`: the MySQL host to connect to
 - `MYSQL_PORT`: the MySQL port to use
 - `MYSQL_DATABASE`: the database name to be used by Mautic
 - `MYSQL_USER`: the MySQL user that has access to the database
 - `MYSQL_PASSWORD`: the password for the MySQL user 
 - `MYSQL_ROOT_PASSWORD`: the password for the MySQL root user that is able to configure the above users and database

#### PHP settings

 - `PHP_INI_VALUE_DATE_TIMEZONE`: defaults to `UTC`
 - `PHP_INI_VALUE_MEMORY_LIMIT`: defaults to `512M`
 - `PHP_INI_VALUE_UPLOAD_MAX_FILESIZE`: defaults to `512M`
 - `PHP_INI_VALUE_POST_MAX_FILESIZE`: defaults to `512M`
 - `PHP_INI_VALUE_MAX_EXECUTION_TIME`: defaults to `300`

#### Mautic behaviour settings

 - `DOCKER_MAUTIC_ROLE`: which role does the container has to perform.  
   Defaults to `mautic_web`, other supported values are `mautic_worker` and `mautic_cron`.
 - `DOCKER_MAUTIC_LOAD_TEST_DATA`: should the test data be loaded on start or not.  
   Defaults to `false`, other supported value is `true`.  
   This variable is only usable when using the `web` role.
 - `DOCKER_MAUTIC_RUN_MIGRATIONS`: should the Doctrine migrations be executed on start.  
   Defaults to `false`, other supported value is `true`.  
   This variable is only usable when using the `web` role.
 - `DOCKER_MAUTIC_WORKERS_CONSUME_EMAIL`: Number of workers to start consuming mails.  
   Defaults to `2`
 - `DOCKER_MAUTIC_WORKERS_CONSUME_HIT`: Number of workers to start consuming hits.  
   Defaults to `2`
 - `DOCKER_MAUTIC_WORKERS_CONSUME_FAILED`: Number of workers to start consuming failed e-mails.  
   Defaults to `2`

#### Mautic settings

Technically, every setting of Mautic you can set via the UI or via the `local.php` file can be set as environment variable.

e.g. the `messenger_dsn_hit` can be set via the `MAUTIC_MESSENGER_DSN_HIT` environment variable.  
See the general Mautic documentation for more info.

### Customization

Currently this image has no easy way to extend Mautic (e.g. adding extra `composer` dependencies or installing extra plugins or themes).  
This is an ongoing effort we hope to support in an upcoming 5.x release.  
  

For now, please build your own images based on the official ones to add the needed dependencies, plugins and themes.

## Day to day tasks

### Running console commands with Docker Compose

if you want to execute commands, you can make use of `docker compose exec`.

A full list of options for the command is available [on the help pages](https://docs.docker.com/engine/reference/commandline/compose_exec/).  
The most important flags used in the examples below are:

* `-u www-data`: execute as the `www-data` user, which is the same user as the webserver runs. This ensures that e.g. file permissions after clearing the cache are correct.
* `-w /var/www/html`: set the working directory to the `/var/www/html` folder, which is the project root of Mautic.

**Examples** 

* Open a shell in the running `mautic_web` container:

    ```
    docker compose exec -u www-data -w /var/www/html mautic_web /bin/bash
    ```

* execute a command in the running `mautic_web` container and return the output directly
    ```
    docker compose exec -u www-data -w /var/www/html mautic_web php ./bin/console
    ```

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/mautic/docker-mautic/issues).

You can also reach the Mautic community through its [online forums](https://www.mautic.org/community/) or the [Mautic Slack channel](https://www.mautic.org/slack/).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/mautic/docker-mautic/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
