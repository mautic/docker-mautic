FROM php:8.3-fpm AS builder

LABEL vendor="Mautic"
LABEL maintainer="Mautic core team <>"

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    build-essential  \
    git \
    curl \
    libcurl4-gnutls-dev \
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
    librabbitmq-dev \
    unzip \
    nodejs \
    npm

RUN curl -L -o /tmp/amqp.tar.gz "https://github.com/php-amqp/php-amqp/archive/refs/tags/v2.1.2.tar.gz" \
    && mkdir -p /usr/src/php/ext/amqp \
    && tar -C /usr/src/php/ext/amqp -zxvf /tmp/amqp.tar.gz --strip 1 \
    && rm /tmp/amqp.tar.gz

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install intl mbstring mysqli curl pdo_mysql zip bcmath sockets exif amqp gd imap opcache \
    && docker-php-ext-enable intl mbstring mysqli curl pdo_mysql zip bcmath sockets exif amqp gd imap opcache

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN echo "memory_limit = -1" > /usr/local/etc/php/php.ini

# Define Mautic version by package tag
ARG MAUTIC_VERSION=5.2.6

RUN cd /opt && \
    COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer create-project mautic/recommended-project:${MAUTIC_VERSION} mautic --no-interaction && \
    rm -rf /opt/mautic/var/cache/js && \
    find /opt/mautic/node_modules -mindepth 1 -maxdepth 1 -not \( -name 'jquery' -or -name 'vimeo-froogaloop2' \) | xargs rm -rf

COPY ./bme-patches /bme-patches
RUN cd /opt/mautic/docroot && \
    patch -s -p1 < /bme-patches/0001-Use-Be-My-Eyes-unsubscribe-URL.patch

RUN cd /opt/mautic && \
    COMPOSER_ALLOW_SUPERUSER=1 composer require ilkkao/mautic-amazon-ses

FROM php:8.3-fpm

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

COPY --from=builder --chown=www-data:www-data /opt/mautic /var/www/html

# Install PHP extensions requirements and other dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    unzip \
    libwebp-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libc-client-dev \
    librabbitmq4 \
    mariadb-client \
    supervisor \
    cron \
    libfcgi-bin \
    git \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/*

# Install Node.JS (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Setting PHP properties
ENV PHP_INI_VALUE_DATE_TIMEZONE='UTC' \
    PHP_INI_VALUE_MEMORY_LIMIT=512M \
    PHP_INI_VALUE_UPLOAD_MAX_FILESIZE=512M \
    PHP_INI_VALUE_POST_MAX_FILESIZE=512M \
    PHP_INI_VALUE_MAX_EXECUTION_TIME=300

COPY ./common/php.ini /usr/local/etc/php/php.ini

# Rebuild web assets
RUN cd /var/www/html && \
          npm install && \
          php bin/console mautic:assets:generate && \
          php /var/www/html/bin/console cache:clear

COPY ./common/docker-entrypoint.sh /entrypoint.sh
COPY ./common/entrypoint_mautic_web.sh /entrypoint_mautic_web.sh
COPY ./common/entrypoint_mautic_cron.sh /entrypoint_mautic_cron.sh
COPY ./common/entrypoint_mautic_worker.sh /entrypoint_mautic_worker.sh

# Apply necessary permissions
RUN ["chmod", "+x", "/entrypoint.sh", "/entrypoint_mautic_web.sh", "/entrypoint_mautic_cron.sh", "/entrypoint_mautic_worker.sh"]

# Setting worker env vars
ENV DOCKER_MAUTIC_WORKERS_CONSUME_EMAIL=2 \
    DOCKER_MAUTIC_WORKERS_CONSUME_HIT=2 \
    DOCKER_MAUTIC_WORKERS_CONSUME_FAILED=2

COPY ./common/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install composer
COPY --from=builder /usr/bin/composer /usr/bin/composer

# Set correct ownership for Mautic cache
RUN chown -R www-data:www-data /var/www/html/var/cache/

# Define Mautic volumes to persist data
VOLUME /var/www/html/config
VOLUME /var/www/html/var/logs
VOLUME /var/www/html/docroot/media

WORKDIR /var/www/html/docroot

ENV DOCKER_MAUTIC_ROLE=mautic_web \
    DOCKER_MAUTIC_RUN_MIGRATIONS=false \
    DOCKER_MAUTIC_LOAD_TEST_DATA=false

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
