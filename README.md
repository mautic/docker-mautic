# Official Mautic Docker Image
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-14-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

> [!NOTE]
> _This version refers to Docker images and examples for Mautic 5 and above, previous Mautic versions aren't actively supported anymore. If you would like information about older versions, see https://github.com/mautic/docker-mautic/tree/mautic4._

## Issues

> [!IMPORTANT]
>You might face several issues when using the FPM images, due to the way those are currently implemented. **We strongly advise using Apache instead of FPM for the time being**. You might face security issues when using the exemplified nginx.conf. Only proceed with FPM if you are familiar with Nginx configuration!
>Please refer to [#317](https://github.com/mautic/docker-mautic/issues/317) for updates on this topic.

For general questions about this Docker image, please visit [our forum](https://forum.mautic.org/c/support/docker-support/112). We ask that you only open [GitHub issues](https://github.com/mautic/docker-mautic/issues) for bug reports or feature requests. This helps ensure you get wider community support and allows others with similar questions to find answers more easily.

To reach the developers directly, you can find us in the #docker channel on [Mautic's Slack](https://www.mautic.org/slack/).

## Versions

All Mautic 5 and above Docker images follow the following naming stategy.

`<major.minor.patch>-<variant>`

There are some defaults if parts are omitted:

* `<minor.patch>` is the latest release patch version in the latest minor version.

Some examples:

* `6-apache`: latest stable version of Mautic 6 of the `apache` variant
* `6.0-fpm`: latest version in the 6.0 minor release in the `fpm` variant 
* `6.0.6-apache`: specific point release of the `apache` variant


Additionally, the tag `latest` is available, which will always provide the newest stable Mautic version using the `apache` variant of the Docker image.

It's also possible to target a specific build for a given patch:

* `<major.minor.patch>-<YYYYMMDD>-<variant>`

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
> it shows how it **could** be used, not how it **should** be used.  
> Do not use those examples in production without reviewing, understanding and configuring them.

* [basic](examples/basic/): standard example using the `apache` image with `doctrine` as async queue.
* [fpm-nginx](examples/fpm-nginx/): example using the `fpm` image in combination with an `nginx` with `doctrine` as async queue.
* [rabbitmq-worker](examples/rabbitmq-worker/): example using the `apache` image with `rabbitmq` as async queue.
* [custom-plugins](examples/custom-plugins/): example using a custom build based on `apache` to install non-marketplace plugins on Mautic.

For each example, there are 2 files where settings can be set:

* the `.env` file: 
  Should be used for all general variables for Mysql, PHP, ...
* the `.mautic_env` file:
  Should be used for all Mautic specific variables.

## Building your own images

You can build your own images easily using the `docker build` command in the root of this directory, parsing the following ARGs depending on the version you wish to build:

Version | MAUTIC_VERSION | BASE_TAG | FLAVOUR
---|---|---|---
5.2.X (Apache) | `5.2.0` to `5.2.8` | 8.2-apache-bookworm | apache
5.2.X (FPM) | `5.2.0` to `5.2.8` | 8.2-fpm-bookworm | fpm
6.X.X (Apache) | `6.0.0` to `6.0.6` | 8.3-apache-bookworm | apache
6.X.X (FPM) | `6.0.0` to `6.0.6` | 8.3-fpm-bookworm | fpm
7.X.X (Apache) | `7.0.0-beta` | 8.4-apache-bookworm | apache
7.X.X (FPM) | `7.0.0-beta` | 8.4-fpm-bookworm | fpm

### Example

To build Mautic 6.0.6 apache, run:
```
docker buildx build --build-arg FLAVOUR=apache --build-arg BASE_TAG=8.3-apache-bookworm --build-arg MAUTIC_VERSION=6.0.6 -t mautic/mautic:6-apache .
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

Variable | Default | Required | Accepted Values | Description
---|---|---|---|---
`DEBUG` | false | ✖️ | `true`, `false` | Enable verbose logs
`DOCKER_MAUTIC_ROLE` | mautic_web | ✖️ | `mautic_cron`, `mautic_web`, `mautic_worker (string) | Container role
`DOCKER_MAUTIC_LOAD_TEST_DATA` | false | ✖️ | `true`, `false` | Load demo instance
`DOCKER_MAUTIC_WORKERS_CONSUME_EMAIL` | 2 | ✖️ | integer | Number of workers to start consuming e-mails
`DOCKER_MAUTIC_WORKERS_CONSUME_HIT` | 2 | ✖️ | integer | Number of workers to start consuming hits
`DOCKER_MAUTIC_WORKERS_CONSUME_FAILED` | 2 | ✖️ | integer | Number of workers to start consuming failed e-mails
`MAUTIC_DB_HOST` | *none* | ☑️ | IPv4, IPv6, hostname | MySQL server's IP address or hostname
`MAUTIC_DB_PORT` | 3306 | ✖️ | 1 - 65535 (integer) | MySQL server's port
`MAUTIC_DB_DATABASE` | *none* | ☑️ | string | Database which holds Mautic's tables
`MAUTIC_DB_USER` | *none* | ☑️ | string | MySQL user for Mautic
`MAUTIC_DB_PASSWORD` | *none* | ☑️ | string | MySQL password for Mautic

##### PHP Settings
Variable | Default
---|---
`PHP_INI_VALUE_DATE_TIMEZONE` | `UTC`
`PHP_INI_VALUE_MEMORY_LIMIT` | `512M`
`PHP_INI_VALUE_UPLOAD_MAX_FILESIZE` | `512M`
`PHP_INI_VALUE_POST_MAX_FILESIZE` | `512M`
`PHP_INI_VALUE_MAX_EXECUTION_TIME` | `300`

#### Mautic settings

Technically, every setting of Mautic you can set via the UI or via the `local.php` file can be set as environment variable.

e.g. the `messenger_dsn_hit` can be set via the `MAUTIC_MESSENGER_DSN_HIT` environment variable.  
See the general Mautic documentation for more info.

### Customization

Build a derived image to add Composer dependencies, plugins or themes. Composer's
installation and update scripts require Node/npm, including `npm ci` in Mautic
7.2.1. Run these commands in a builder stage and copy the resulting application
into a runtime stage based on the same Mautic image.

The [custom-plugins example](examples/custom-plugins/README.md) provides this
workflow, build commands and a Compose setup for the web, cron and worker roles.
Node/npm and frontend build tools stay in the builder stage.

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
docker compose exec --user www-data --workdir /var/www/html mautic_web php ./bin/console mautic:install https://mautic.example.com --admin_email="admin@mautic.local" --admin_password="Maut1cR0cks\!"
```

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
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cibero42"><img src="https://avatars.githubusercontent.com/u/102629460?v=4?s=100" width="100px;" alt="Renato"/><br /><sub><b>Renato</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=cibero42" title="Code">💻</a> <a href="https://github.com/mautic/docker-mautic/commits?author=cibero42" title="Documentation">📖</a> <a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Acibero42" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/mautic/docker-mautic/commits?author=cibero42" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://academy.leewayweb.com"><img src="https://avatars.githubusercontent.com/u/1532615?v=4?s=100" width="100px;" alt="Mauro Chojrin"/><br /><sub><b>Mauro Chojrin</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=mchojrin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://okeefe.dev"><img src="https://avatars.githubusercontent.com/u/872224?v=4?s=100" width="100px;" alt="Matt O'Keefe"/><br /><sub><b>Matt O'Keefe</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Ao-mutt" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.4success.com.br"><img src="https://avatars.githubusercontent.com/u/19995615?v=4?s=100" width="100px;" alt="Renan William"/><br /><sub><b>Renan William</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=renanwilliam" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.ruthcheesley.co.uk"><img src="https://avatars.githubusercontent.com/u/2930593?v=4?s=100" width="100px;" alt="Ruth Cheesley"/><br /><sub><b>Ruth Cheesley</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=RCheesley" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://johnlinhart.com"><img src="https://avatars.githubusercontent.com/u/1235442?v=4?s=100" width="100px;" alt="John Linhart"/><br /><sub><b>John Linhart</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Aescopecz" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ChiragMoradiya"><img src="https://avatars.githubusercontent.com/u/2399621?v=4?s=100" width="100px;" alt="Chirag Moradiya"/><br /><sub><b>Chirag Moradiya</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=ChiragMoradiya" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/matbcvo"><img src="https://avatars.githubusercontent.com/u/1006437?v=4?s=100" width="100px;" alt="Martin Vooremäe"/><br /><sub><b>Martin Vooremäe</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=matbcvo" title="Code">💻</a> <a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Amatbcvo" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/henmohr"><img src="https://avatars.githubusercontent.com/u/21038820?v=4?s=100" width="100px;" alt="henmohr"/><br /><sub><b>henmohr</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Ahenmohr" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/maxitromer"><img src="https://avatars.githubusercontent.com/u/6311835?v=4?s=100" width="100px;" alt="maxitromer"/><br /><sub><b>maxitromer</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=maxitromer" title="Code">💻</a> <a href="https://github.com/mautic/docker-mautic/commits?author=maxitromer" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nick-vanpraet"><img src="https://avatars.githubusercontent.com/u/7923739?v=4?s=100" width="100px;" alt="Nick Vanpraet"/><br /><sub><b>Nick Vanpraet</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/pulls?q=is%3Apr+reviewed-by%3Anick-vanpraet" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://druid.fi"><img src="https://avatars.githubusercontent.com/u/1140272?v=4?s=100" width="100px;" alt="Marko Korhonen"/><br /><sub><b>Marko Korhonen</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=back-2-95" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.petchblog.net/"><img src="https://avatars.githubusercontent.com/u/76615399?v=4?s=100" width="100px;" alt="Kiart Tantasi"/><br /><sub><b>Kiart Tantasi</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=kiart-tantasi" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Aarplexan"><img src="https://avatars.githubusercontent.com/u/72907341?v=4?s=100" width="100px;" alt="Aarplexan"/><br /><sub><b>Aarplexan</b></sub></a><br /><a href="https://github.com/mautic/docker-mautic/commits?author=Aarplexan" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
