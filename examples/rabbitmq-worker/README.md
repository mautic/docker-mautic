# Mautic Docker deployment with RabbitMQ Worker

This example demonstrates how to run Mautic with RabbitMQ as the message queue system for handling asynchronous tasks and assume the use of Docker Compose v2 including best practices for running Mautic with RabbitMQ in a containerized environment.

Also adds the possibility of importing files in background (See mautic_web-entrypoint_custom.sh)

## Prerequisites

- [Docker Engine 20.10.0 or newer](https://docs.docker.com/get-started/get-docker/)
- [Docker Compose v2.0.0 or newer](https://docs.docker.com/compose/install/)
- [Git (for cloning the repository)](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Directory Structure
```
rabbitmq-worker/                     # Root project directory
├── .env                             # Docker Compose Global environment variables
├── .mautic_env                      # Docker Compose Mautic specific environment variables
├── docker-compose.yml               # Docker Compose configuration file
├── mautic_web-entrypoint_custom.sh  # Custom Docker Image Entrypoint for Docker Mautic Image used in Web container
├── undeploy.sh                      # Undeploy application from you Docker Host
├── volumes/                         # Created at execution for container storage
│   ├── mautic/                      # Mautic specific shared directories
│   │   ├── config/                  # Configuration files
│   │   ├── cron/                    # Cron files
│   │   ├── logs/                    # Application logs
│   │   └── media/                   # Media storage
│   │       ├── files/               # Uploaded files
│   │       └── images/              # Uploaded images
│   ├── mysql/                       # MySQL data storage
│   ├── rabbitmq/                    # RabbitMQ data storage
└── README.md                        # This file instructions
```

## Configuration

1. Create the required directories:
```bash
mkdir -p mautic/{config,logs,media/{files,images}}
```
2. Copy the example environment files:

```bash
cp ../../.env.example .env
cp ../../.mautic_env.example .mautic_env
```
3. Configure the .env file with your database settings:
```bash
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=mautic
MYSQL_USER=mautic
MYSQL_PASSWORD=your_password
COMPOSE_PROJECT_NAME=mautic-rabbitmq
```

4. Configure the .mautic_env file with RabbitMQ settings:
```bash
MAUTIC_DB_HOST=mysql
MAUTIC_DB_USER=mautic
MAUTIC_DB_PASSWORD=your_password
MAUTIC_DB_NAME=mautic
MAUTIC_MESSENGER_TRANSPORT_DSN=amqp://guest:guest@rabbitmq:5672/%2f/messages
MAUTIC_MESSENGER_TRANSPORT_FAILED_DSN=doctrine://default?queue_name=failed
MAUTIC_MESSENGER_TRANSPORT_DELAY_DSN=doctrine://default?queue_name=delay
```

5. Change sections variables in <b><i>enviroment</i></b> of  <b>docker-compose.yml</b> file for specific settings of each container and also the resources limits of each service as CPU and RAM.

## Deployment

1. Start the services:
```bash
docker compose up -d
```
2. Monitor the startup process:
```bash
docker compose up -d
````
3. Access Mautic:

- Web Interface: http://localhost:8001

- RabbitMQ Management Interface: http://localhost:15672 (default credentials: guest/guest)

## Maintenance

### Queue Management

Monitor RabbitMQ queues:
````bash
docker compose exec -u www-data mautic_web php bin/console messenger:status
````
View message consumers status:
````bash
docker compose exec -u www-data mautic_worker php bin/console messenger:consume async
````
## Logs
#### View Mautic logs:
```bash
docker compose exec mautic_web tail -f /var/www/html/var/logs/mautic.log
```
#### View RabbitMQ logs:
```bash
docker compose logs rabbitmq
````

### Backup

Backup can be done from the directory <b><i>./volumes</i></b>Created at the Docker Engine host or remotely through the following commands:

#### Backup RabbitMQ definitions:

```bash
docker compose exec rabbitmq rabbitmqctl export_definitions /tmp/rabbitmq-definitions.json

docker cp $(docker compose ps -q rabbitmq):/tmp/rabbitmq-definitions.json ./rabbitmq-definitions.json
```

#### Backup Mautic data:
##### Backup database
```bash
docker compose exec db mysqldump -u root -p$MYSQL_ROOT_PASSWORD mautic > mautic_backup.sql
````
#### Backup Mautic files
```bash
docker compose exec mautic_web tar czf /tmp/mautic-files.tar.gz /var/www/html/config /var/www/html/media
docker cp $(docker compose ps -q mautic_web):/tmp/mautic-files.tar.gz ./mautic-files.tar.gz
```

## Scaling Workers

#### To scale the number of worker containers:
```bash
docker compose up -d --scale mautic_worker=3
```

## Undeploy containers

Undeplay Containers and delete all associated resources:
```bash
bash undeploy.sh
```

## Troubleshooting

#### Check service health:
```bash
docker compose ps
```

#### Verify RabbitMQ connectivity:
```bash
docker compose exec mautic_web php bin/console messenger:setup-transport
```

#### Clear Mautic cache:
```bash
docker compose exec -u www-data mautic_web php bin/console cache:clear
```

#### Reset failed messages:
```bash
docker compose exec -u www-data mautic_web php bin/console messenger:failed:retry
```
## Security Considerations
- Change default RabbitMQ credentials in production
- Enable SSL/TLS for RabbitMQ connections
- Regularly update all containers to their latest versions
- Monitor queue sizes and consumer health
- Implement proper backup strategies

## Additional Official Resources
- [Mautic Website](https://github.com/mautic)
- [Mautic Documentation](https://docs.mautic.org/en/5.x/)
- [Mautic Forum](https://forum.mautic.org/)
- [Mautic at Docker Hub](https://hub.docker.com/r/mautic/mautic)
- [Mautic at GitHub](https://github.com/mautic)
- [RabbitMQ Documentation](https://www.rabbitmq.com/docs)
- [Docker Documentation](https://docs.docker.com/compose/)
