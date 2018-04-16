FROM php:7.0-fpm

LABEL maintainer="Michael Babker <michael.babker@mautic.org> (@mbabker)"

# Install PHP extensions and clear all apt-cache
RUN apt-get update && apt-get install --no-install-recommends -y \
    cron \
    git \
    wget \
    libc-client-dev \
    libicu-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libssl-dev \
    unzip \
    zip \
    git \
    wget \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/*

# Configure php extensions and install
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap intl mbstring mcrypt mysqli pdo pdo_mysql zip

# Define Mautic volume to persist data
VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.12.2
ENV MAUTIC_SHA1 081b467829b9cc3ddb81f90d855e31e9da6535ab

# By default enable cron jobs
ENV MAUTIC_RUN_CRON_JOBS true

# Setting an root user for test
ENV MAUTIC_DB_USER root

# Setting an mautic DB Name for test
ENV MAUTIC_DB_NAME mautic

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

# Copy default crontab
COPY mautic.crontab /etc/cron.d/mautic

# Copy custom PHP configurations
COPY mautic-php.ini /usr/local/etc/php/conf.d/mautic-php.ini

# Apply necessary permissions
RUN ["chmod", "+x", "/entrypoint.sh"]

# Starting...
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
