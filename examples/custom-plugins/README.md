# Mautic With Custom Plugins Template

This directory provides a setup to run [Mautic](https://www.mautic.org/) using Docker Compose. It builds a custom image on top of the official Apache-based Mautic Docker image and includes MySQL for storage.

> [!IMPORTANT]
> **Security Notice:**
> Be sure to change the `MYSQL_PASSWORD` and `MYSQL_ROOT_PASSWORD` environment variables under [.env](.env) before deploying to production.

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/mautic/docker-mautic.git
   cd docker-mautic/examples/custom-plugins
   ```

2. Create a `plugins` subdirectory and add your plugins (one directory per plugin).
   Leave the directory empty if you only use Composer packages.

   ```bash
   mkdir plugins
   cp -r /your/plugins/path plugins/
   ```

3. Set the database passwords in `.env`, then build and start the environment:

   ```bash
   docker compose build
   docker compose up -d
   ```

4. Access Mautic in your browser at:
   [http://localhost:8080](http://localhost:8080)

## Composer dependencies and frontend builds

The Dockerfile uses the same `MAUTIC_IMAGE` in both stages, defaulting to
`mautic/mautic:7.2.1-apache`. The builder installs Node.js, npm and native build
tools so Composer can execute its scripts, including the `npm ci` called by
Mautic's `post-update-cmd`. Scripts remain enabled when installing packages.

To add a Composer package, replace `vendor/plugin:^1.0` with a package and version
constraint compatible with your Mautic release:

```bash
docker compose build --build-arg COMPOSER_PACKAGE='vendor/plugin:^1.0'
docker compose up -d
```

For multiple packages or custom Composer repositories, edit the builder stage
before the asset generation and cleanup step. If a plugin needs its own frontend
build, add its documented commands there as well, then remove its `node_modules`
and build cache while retaining its generated assets.

The builder generates Mautic assets and removes the core frontend build
dependencies and cache. The final stage copies the application, including
Composer dependencies and generated assets, into the original runtime image. It
inherits that image's PHP configuration, entrypoint and role support without
copying Node/npm or system build tools.

To select another Apache release, pass the same image to both stages:

```bash
docker compose build --build-arg MAUTIC_IMAGE=mautic/mautic:7.2.1-apache
docker compose up -d
```

Rebuild all three services after changing plugins or Composer requirements so
web, cron and workers use the same application. Activate newly installed plugins
with Mautic's plugin management after starting the environment.

## Configuration

You can configure environment variables in the [.env](.env) file. **Make sure to update the following before deploying to production:**

```yaml
MYSQL_PASSWORD=mautic_db_pwd
MYSQL_ROOT_PASSWORD=changeme
```

You may also want to map volumes or adjust ports as needed.

## Cleanup

To stop and remove the containers:

```bash
docker compose down
```

To remove all volumes (this will delete your data):

```bash
docker-compose down -v
```

## 📘 Resources

* [Mautic Documentation](https://docs.mautic.org/)
* [Mautic Docker GitHub](https://github.com/mautic/docker-mautic)
