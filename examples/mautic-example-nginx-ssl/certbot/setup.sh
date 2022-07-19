#!/bin/bash
LETSENCRYPT_EMAIL="bills@weberon.net"
SERVER_HOSTNAME="pilotdev8.thrivebrokers.com"

##How to install Docker on Ubuntu
#Add the GPG key and add the Docker repository from APT sources
#refer the document for process to setup certbot using docker https://www.humankode.com/ssl/how-to-set-up-free-ssl-certificates-from-lets-encrypt-using-docker-and-nginx
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
apt-get update -y && apt-get install -y build-essential docker-compose git wget curl vim openssl 

#How to set up and run Nginx in a Docker container
#Set up Docker, Nginx and Certbot To Obtain Your First Let's Encrypt SSL/TLS Certificate
mkdir -p /docker/letsencrypt-docker-nginx/src/letsencrypt/letsencrypt-site
#touch /docker/letsencrypt-docker-nginx/src/letsencrypt/docker-compose.yml
cat > /docker/letsencrypt-docker-nginx/src/letsencrypt/docker-compose.yml <<- EOM
version: '3.1'

services:

  letsencrypt-nginx-container:
    container_name: 'letsencrypt-nginx-container'
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - ./letsencrypt-site:/usr/share/nginx/html
    networks:
      - docker-network

networks:
  docker-network:
    driver: bridge
EOM

cat > /docker/letsencrypt-docker-nginx/src/letsencrypt/nginx.conf <<- EOM
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_HOSTNAME;

    location ~ /.well-known/acme-challenge {
        allow all;
        root /usr/share/nginx/html;
    }

    root /usr/share/nginx/html;
    index index.html;
}
EOM

echo """
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Let's Encrypt First Time Cert Issue Site</title>
</head>
<body>
    <h1>Oh, hai there!</h1>
    <p>
        This is the temporary site that will only be used for the very first time SSL certificates are issued by Let's Encrypt's
        certbot.
    </p>
</body>
</html>
""" > /docker/letsencrypt-docker-nginx/src/letsencrypt/letsencrypt-site/index.html

cd /docker/letsencrypt-docker-nginx/src/letsencrypt
docker-compose up -d
docker-compose ps
#request production ssl certificicates from letsencrypt
sudo docker run -it --rm \
-v /docker-volumes/etc/letsencrypt:/etc/letsencrypt \
-v /docker-volumes/var/lib/letsencrypt:/var/lib/letsencrypt \
-v /docker/letsencrypt-docker-nginx/src/letsencrypt/letsencrypt-site:/data/letsencrypt \
-v "/docker-volumes/var/log/letsencrypt:/var/log/letsencrypt" \
certbot/certbot \
certonly --webroot \
--email $LETSENCRYPT_EMAIL --agree-tos --no-eff-email \
--webroot-path=/data/letsencrypt \
-d $SERVER_HOSTNAME
#If everything ran successfully, run a docker-compose down command to stop the temporary Nginx site
cd /docker/letsencrypt-docker-nginx/src/letsencrypt
docker-compose down

#Create the directories for our production site

mkdir -p /docker/letsencrypt-docker-nginx/src/production/production-site
mkdir -p /docker/letsencrypt-docker-nginx/src/production/dh-param

openssl dhparam -out /docker/letsencrypt-docker-nginx/src/production/dh-param/dhparam-2048.pem 2048

cat > /docker/letsencrypt-docker-nginx/src/production/docker-compose.yml 
version: "2"
services:
  mautic-server:
    container_name: mautic-server
    restart: unless-stopped
    image: mautic/mautic
    depends_on:
      - mysql
    ports:
      - "127.0.0.1:80:80"
    environment:
      - MAUTIC_DB_HOST=mysql
      - MAUTIC_DB_USER=mautic
      - MAUTIC_DB_PASSWORD=mauticdbpass
      - MAUTIC_TRUSTED_PROXIES=0.0.0.0/0
      - PHP_INI_DATE_TIMEZONE=UTC
      - PHP_MEMORY_LIMIT=512M
      - PHP_MAX_UPLOAD=30M
      - PHP_MAX_EXECUTION_TIME=300
      - MAUTIC_RUN_CRON_JOBS=true
    volumes:
      - ./production-site:/var/www/html

  mysql:
    restart: unless-stopped
    image: mysql:5.6
    environment:
      MYSQL_ROOT_PASSWORD: mysqlrootpassword
      MYSQL_DATABASE: mautic
      MYSQL_USER: mautic
      MYSQL_PASSWORD: mauticdbpass
    volumes:
      - ./mysql:/var/lib/mysql

  webserver:
    restart: unless-stopped
    image: nginx
    ports:
      - "443:443"
    volumes:
      - ./production.conf:/etc/nginx/conf.d/default.conf
      - ./dh-param/dhparam-2048.pem:/etc/ssl/certs/dhparam-2048.pem
      - /docker-volumes/etc/letsencrypt/live/$SERVER_HOSTNAME:/etc/letsencrypt/live/$SERVER_HOSTNAME
      - /docker-volumes/etc/letsencrypt/archive/$SERVER_HOSTNAME:/etc/letsencrypt/archive/$SERVER_HOSTNAME
    depends_on:
      - mautic-server
EOM

cat > /docker/letsencrypt-docker-nginx/src/production/production.conf 
server {
        listen 443 ssl default_server;
        ssl_dhparam /etc/ssl/certs/dhparam-2048.pem;
        ssl_certificate     /etc/letsencrypt/live/$SERVER_HOSTNAME/cert.pem;
        ssl_certificate_key /etc/letsencrypt/live/$SERVER_HOSTNAME/privkey.pem;

        #ssl_certificate     /etc/letsencrypt/archive/beta-mautic.thrivebrokers.com/cert1.pem;
        #ssl_certificate_key /etc/letsencrypt/archive/beta-mautic.thrivebrokers.com/privkey1.pem;
        location / {
        proxy_set_header        Host               $host;
        proxy_set_header        X-Forwarded-For    $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto  $scheme;

        # drop unused proxy headers to prevent clients from tampering with them
        proxy_set_header        X-Forwarded-Port   "";
        proxy_set_header        Forwarded   "";
        proxy_set_header        X-Real-IP   "";
        proxy_set_header        X-Forwarded-Host "";

        proxy_pass http://beta-mautic/;

        # sometimes apache mod_rewrite redirects to absolute http:// urls. Replace those with https:// urls
        proxy_redirect http://$SERVER_HOSTNAME https://$SERVER_HOSTNAME;

        }

}
	  
