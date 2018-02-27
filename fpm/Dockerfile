FROM php:7.0-fpm
MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
    cron \
    libc-client-dev \
    libicu-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libssl-dev \
    unzip \
    zip \
    && rm /etc/cron.daily/*
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap intl mbstring mcrypt mysqli pdo pdo_mysql zip

VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.12.1
ENV MAUTIC_SHA1 68eae0b27442b32f24d41cb4bea8fbfaa2f9772e

ENV MAUTIC_RUN_CRON_JOBS true
ENV MAUTIC_DB_USER root
ENV MAUTIC_DB_NAME mautic

# DEFINE CRON SCHEDULE VARIABLES
ENV MAUTIC_CRON_SEGMENTS_UPDATE "8,23,38,52 * * * *"
ENV MAUTIC_CRON_IMPORT "*/5 * * * *"
ENV MAUTIC_CRON_CAMPAIGN_REBUILD "5,20,35,50 * * * *"
ENV MAUTIC_CRON_CAMPAIGN_TRIGGER "2,17,32,47 * * * *"
ENV MAUTIC_CRON_EMAILS_SEND "0,15,30,45 * * * *"
ENV MAUTIC_CRON_EMAIL_FETCH "0,15,30,45 * * * *"
ENV MAUTIC_CRON_SOCIAL_MONITORING "0,15,30,45 * * * *"
ENV MAUTIC_CRON_MESSAGES_SEND "0,15,30,45 * * * *"
ENV MAUTIC_CRON_WEBHOOKS_PROCESSS "0,15,30,45 * * * *"
ENV MAUTIC_CRON_BROADCASTS_SEND "0,15,30,45 * * * *"
ENV MAUTIC_CRON_MAINTENANCE "* 1 * * *"
ENV MAUTIC_CRON_IPLOOKUP "0 4 15 * *"
ENV MAUTIC_CRON_REPORTS_SCHEDULER "*/5 * * * *"

# Download package and extract to web volume
RUN curl -o mautic.zip -SL https://s3.amazonaws.com/mautic/releases/${MAUTIC_VERSION}.zip \
	&& echo "$MAUTIC_SHA1 *mautic.zip" | sha1sum -c - \
	&& mkdir /usr/src/mautic \
	&& unzip mautic.zip -d /usr/src/mautic \
	&& rm mautic.zip \
	&& chown -R www-data:www-data /usr/src/mautic

# Copy init scripts and custom .htaccess
COPY docker-entrypoint.sh /entrypoint.sh
COPY makeconfig.php /makeconfig.php
COPY makedb.php /makedb.php
COPY mautic.crontab /etc/cron.d/mautic
COPY mautic-php.ini /usr/local/etc/php/conf.d/mautic-php.ini

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
