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

2. Crete a `plugins` subdirectory, and add your plugins

   ```bash
   mkdir plugins
   cp /your/plugins/path plugins/
   ```

3. Start the environment:

   ```bash
   docker compose up -d
   ```

4. Access Mautic in your browser at:
   [http://localhost:8080](http://localhost:8080)

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
