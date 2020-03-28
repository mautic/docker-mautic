FROM php:7.2-fpm

LABEL vendor="Mautic"
LABEL maintainer="Luiz Eduardo Oliveira Fonseca <luiz@powertic.com>"

# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
    cron \
    git \
    wget \
    sudo \
    unzip \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/*

# Install PHP extensions
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libc-client-dev \
        libicu-dev \
        libkrb5-dev \
        libssl-dev \
        libz-dev \
    ; \
    \
    docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos; \
    docker-php-ext-install -j "$(nproc)" \
        bcmath \
        imap \
        intl \
        mysqli \
        opcache \
        pdo_mysql \
        zip \
    ; \
    \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual; \
    \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Define Mautic volume to persist data
VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.16.0
ENV MAUTIC_SHA1 94ced007fd99e63eaeec435012784b6bbe834b84

# By default enable cron jobs
ENV MAUTIC_RUN_CRON_JOBS true

# Setting an root user for test
ENV MAUTIC_DB_USER root
ENV MAUTIC_DB_NAME mautic

# Setting PHP properties
ENV PHP_INI_DATE_TIMEZONE='UTC' \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_UPLOAD=128M \
    PHP_MAX_EXECUTION_TIME=300

# Download package and extract to web volume
RUN curl -o mautic.zip -SL https://github.com/mautic/mautic/releases/download/${MAUTIC_VERSION}/${MAUTIC_VERSION}.zip \
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
RUN chmod 644 /etc/cron.d/mautic

# Apply necessary permissions
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
