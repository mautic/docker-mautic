# Mautic Docker image and examples
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

> [!NOTE]
> _This version refers to Docker images and examples for Mautic 5, previous Mautic versions aren't actively supported anymore. If you would like information about older versions, see <https://github.com/mautic/docker-mautic/tree/mautic4>._

> [!IMPORTANT]
>You might face several issues when using the FPM images, due to the way those are currently implemented. **We strongly advise using Apache instead of FPM for the time being**. You might face security issues when using the exemplified nginx.conf. Only proceed with FPM if you are familiar with Nginx configuration!
>Please refer to [#317](https://github.com/mautic/docker-mautic/issues/317) for updates on this topic.

## Versions

All Mautic 5 Docker images follow the following naming stategy.

`<major.minor.patch>-<variant>`

There are some defaults if parts are omitted:

* `<minor.patch>` is the latest release patch version in the latest minor version.

Some examples:

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

The [examples](examples/) folder contains examples of `docker-compose` setups that use the Docker images.

> [!WARNING]
> The examples **require `docker compose` v2**.  
> Running the examples with the unsupported `docker-compose` v1 will result in a non-starting web container.  

> [!IMPORTANT]
> Please take into account the purpose of those examples:  
> It shows how it **could** be used, not how it **should** be used.  
> Do not use those examples in production without reviewing, understanding and configuring them.

* `basic`: standard example using the `apache` image with `doctrine` as async queue.
* `docker-secrets`: example using `_FILE` secrets to show loading secrets from files into the containers.
* `fpm-nginx`: example using the `fpm` image in combination with an `nginx` with `doctrine` as async queue.
* `rabbitmq-worker`: example using the `apache` image with `rabbitmq` as async queue.

For each example, there are 2 files where settings can be set:

* the `.env` file:
  Should be used for all general variables for Mysql, PHP, ...
* the `.mautic_env` file:
  Should be used for all Mautic specific variables.

## Building your own images

You can build your own images easily using the `docker build` command in the root of this directory:

```bash
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

#### Environment Variables

The following environment variables can be used to configure how your setup should behave.

##### Mautic Behaviour

* `MAUTIC_DB_HOST`: IP address or hostname of the MySQL server. (Also see [docker secrets](#docker-secrets-support))
* `MAUTIC_DB_PORT`: port which the MySQL server is listening on. (Also see [docker secrets](#docker-secrets-support))
  * Default: `3306`.
* `MAUTIC_DB_DATABASE`: Database which holds Mautic's tables.
* `MAUTIC_DB_USER`: MySQL user which should be used by Mautic. (Also see [docker secrets](#docker-secrets-support))
* `MAUTIC_DB_PASSWORD`: Password of the MySQL user which should be used by Mautic. (Also see [docker secrets](#docker-secrets-support))
* `DOCKER_MAUTIC_ROLE`: which role does the container has to perform.  
  * Default: `mautic_web`
  * other supported values are `mautic_worker` and `mautic_cron`.
* `DOCKER_MAUTIC_LOAD_TEST_DATA`: should the test data be loaded on start or not.
  * Default: `false`.
  * Supported values: `false`, `true`.
  * _Note:_ This variable is only usable when using the `mautic_web` role.
* `DOCKER_MAUTIC_RUN_MIGRATIONS`: should the Doctrine migrations be executed on start.
  * Default: `false`.
  * Supported values: `false`, `true`.
  * _Note:_ This variable is only usable when using the `mautic_web` role.
* `DOCKER_MAUTIC_WORKERS_CONSUME_EMAIL`: Number of workers to start consuming mails.
  * Default: `2`
  * Supported values: any positive number
  * _Note:_ This variable is only usable when using the `mautic_worker` role.
* `DOCKER_MAUTIC_WORKERS_CONSUME_HIT`: Number of workers to start consuming hits.
  * Default: `2`
  * Supported values: any positive number
  * _Note:_ This variable is only usable when using the `mautic_worker` role.
* `DOCKER_MAUTIC_WORKERS_CONSUME_FAILED`: Number of workers to start consuming failed e-mails.
  * Default: `2`
  * Supported values: any positive number
  * _Note:_ This variable is only usable when using the `mautic_worker` role.

##### PHP Settings

* `PHP_INI_VALUE_DATE_TIMEZONE`: defaults to `UTC`
* `PHP_INI_VALUE_MEMORY_LIMIT`: defaults to `512M`
* `PHP_INI_VALUE_UPLOAD_MAX_FILESIZE`: defaults to `512M`
* `PHP_INI_VALUE_POST_MAX_FILESIZE`: defaults to `512M`
* `PHP_INI_VALUE_MAX_EXECUTION_TIME`: defaults to `300`

#### Mautic settings

Technically, every setting of Mautic you can set via the UI or via the `local.php` file can be set as environment variable.

e.g. the `messenger_dsn_hit` can be set via the `MAUTIC_MESSENGER_DSN_HIT` environment variable.

See the [Mautic documentation](https://docs.mautic.org/en/5.2/) for more info.

### Docker Secrets Support

There is allowance for use of [docker secrets](https://docs.docker.com/engine/swarm/secrets/#build-support-for-docker-secrets-into-your-images) for `HOST`, `PORT`, `USER`, and `PASSWORD`, via `MAUTIC_DB_*_FILE`. In order to use `docker secrets` you must be part of a docker swarm. You can initialize a swarm by simply using `docker swarm init`.

There are 4 values we currently support for docker secrets:

* `MAUTIC_DB_HOST_FILE`: The file that contains the text host for the db. This maps to `MAUTIC_DB_HOST`. Only 1 of these values can be configured (mutually exclusive).
* `MAUTIC_DB_PORT_FILE`: The file that contains the text port for the db. This maps to `MAUTIC_DB_PORT`. Only 1 of these values can be configured (mutually exclusive).
* `MAUTIC_DB_USER_FILE`: The file that contains the text user for the db. This maps to `MAUTIC_DB_USER`. Only 1 of these values can be configured (mutually exclusive).
* `MAUTIC_DB_PASSWORD_FILE`: The file that contains the text password for the db. This maps to `MAUTIC_DB_PASSWORD`. Only 1 of these values can be configured (mutually exclusive).

See [example compose](./examples/docker-secrets/docker-compose.yml) for an example.

### Customization

Currently this image has no easy way to extend Mautic (e.g. adding extra `composer` dependencies or installing extra plugins or themes).
This is an ongoing effort we hope to support in an upcoming 5.x release.

For now, please build your own images based on the official ones to add the needed dependencies, plugins and themes.

## Day to day tasks

You can execute commands directly against the [Mautic CLI](https://docs.mautic.org/en/5.x/configuration/command_line_interface.html#mautic-commands). To do so you have two options:

1. Connect to the running container and run the commands.
1. Run the commands as `exec` via docker (compose).

Both cases will use `docker compose exec`/`docker exec`. Using `docker compose` uses the `docker-compose.yaml` and the container names listed for ease. More info can be learned about `exec` commands [here](https://docs.docker.com/engine/reference/commandline/compose_exec/).

Note - Two flags that are used commonly in docker Mautic:

1. `--user www-data`
   * execute as the `www-data` user, which is the same user as the webserver runs. Running commands as the correct user ensures things function as expected. e.g. file permissions after clearing the cache are correct.
1. `--workdir /var/www/html`
   * set the working directory to the `/var/www/html` folder, which is the project root of Mautic.

### Connect to the Container

```bash
docker compose exec --user www-data --workdir /var/www/html mautic_web /bin/bash
```

### Running a Mautic CLI command

```bash
docker compose exec --user www-data --workdir /var/www/html mautic_web php ./bin/console mautic:install https://mautic.example.com --admin_email="admin@mautic.local" --admin_password="Maut1cR0cks!"
```

## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/mautic/docker-mautic/issues).

You can also reach the Mautic community through its [online forums](https://www.mautic.org/community/) or the [Mautic Slack channel](https://www.mautic.org/slack/).

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/mautic/docker-mautic/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cibero42"><img src="https://avatars.githubusercontent.com/u/102629460?v=4?s=100" width="100px;" alt="Renato"/><br /><sub><b>Renato</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=cibero42" title="Code">💻</a> <a href="https://github.com/mautic/docker-mautic/commits?author=cibero42" title="Documentation">📖</a> <a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Acibero42" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://academy.leewayweb.com"><img src="https://avatars.githubusercontent.com/u/1532615?v=4?s=100" width="100px;" alt="Mauro Chojrin"/><br /><sub><b>Mauro Chojrin</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=mchojrin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://okeefe.dev"><img src="https://avatars.githubusercontent.com/u/872224?v=4?s=100" width="100px;" alt="Matt O'Keefe"/><br /><sub><b>Matt O'Keefe</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=o-mutt" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.4success.com.br"><img src="https://avatars.githubusercontent.com/u/19995615?v=4?s=100" width="100px;" alt="Renan William"/><br /><sub><b>Renan William</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=renanwilliam" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.ruthcheesley.co.uk"><img src="https://avatars.githubusercontent.com/u/2930593?v=4?s=100" width="100px;" alt="Ruth Cheesley"/><br /><sub><b>Ruth Cheesley</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=RCheesley" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://johnlinhart.com"><img src="https://avatars.githubusercontent.com/u/1235442?v=4?s=100" width="100px;" alt="John Linhart"/><br /><sub><b>John Linhart</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Aescopecz" title="Reviewed Pull Requests">👀</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
