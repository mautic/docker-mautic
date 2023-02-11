FROM php:8.0-apache as builder

LABEL vendor="Mautic"
LABEL maintainer="Mautic core team <>"

# Define Mautic version by package tag
ARG MAUTIC_VERSION 5.x-dev

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    build-essential  \
    software-properties-common \
    cron \
    git \
    htop \
    wget \
    dos2unix \
    curl \
    libcurl4-gnutls-dev \
    sudo \
    libc-client-dev \
    libkrb5-dev \
    libmcrypt-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libpng-dev \
    libgif-dev \
    libtiff-dev \
    libz-dev \
    libpq-dev \
    imagemagick \
    graphicsmagick \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libxpm-dev \
    libaprutil1-dev \
    libicu-dev \
    libfreetype6-dev \
    libonig-dev \
    unzip \
    nano \
    zip \
    mariadb-client \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/*

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap && \
    docker-php-ext-enable imap

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install  gd \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install intl mbstring mysqli curl pdo_mysql zip opcache bcmath gd sockets exif \
    && docker-php-ext-enable intl mbstring mysqli curl pdo_mysql zip opcache bcmath gd sockets exif

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN cd /opt && \
    composer create-project mautic/recommended-project:${MAUTIC_VERSION} mautic --no-interaction --no-install && \
    cd /opt/mautic && \
    composer config --no-plugins allow-plugins.composer/installers true && \
    composer config --no-plugins allow-plugins.symfony/flex true && \
    composer config --no-plugins allow-plugins.mautic/core-composer-scaffold true && \
    composer config --no-plugins allow-plugins.mautic/core-project-message true && \
    composer config --no-plugins allow-plugins.php-http/discovery true && \
    composer install

FROM php:8.0-apache

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY --from=builder --chown=www-data:www-data /opt/mautic /var/www

# Install PHP extensions requirements
RUN apt-get update && apt-get install --no-install-recommends -y \
    unzip libwebp-dev libzip-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libc-client-dev \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/*

# Define Mautic volume to persist data
VOLUME /var/www/

# By default enable cron jobs
ENV MAUTIC_RUN_CRON_JOBS true

# By default disable automatic migrations
ENV MAUTIC_RUN_MIGRATIONS false

# Setting an Default database user for Mysql
ENV MAUTIC_DB_USER root

# Setting an Default database name for Mysql
ENV MAUTIC_DB_NAME mautic

# Set up mysql port
ENV MAUTIC_DB_PORT 3306

# Setting PHP properties
ENV PHP_INI_DATE_TIMEZONE='UTC' \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_UPLOAD=512M \
    PHP_MAX_EXECUTION_TIME=300

RUN sed -i 's/DocumentRoot.*/DocumentRoot \/var\/www\/docroot/g' /etc/apache2/sites-enabled/000-default.conf

# Copy init scripts and custom .htaccess
COPY common/docker-entrypoint.sh /entrypoint.sh
COPY common/makeconfig.php /makeconfig.php
COPY common/makedb.php /makedb.php
COPY common/mautic.crontab /etc/cron.d/mautic

RUN chmod 644 /etc/cron.d/mautic

# Enable Apache Rewrite Module
RUN a2enmod rewrite

WORKDIR /var/www/docroot

# Apply necessary permissions
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
