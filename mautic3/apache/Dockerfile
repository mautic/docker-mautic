FROM php:7.4-apache

LABEL vendor="Mautic" \
      maintainer.1="Luiz Eduardo Oliveira Fonseca <luiz@powertic.com>" \
      maintainer.2="sebastain Mendel <sebastian.mendel@netresearch.de>"

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 3.2.4
ENV MAUTIC_SHA1 291ebabd2f12a0d8eced65a0adaa597db8371a39

# By default enable cron jobs
ENV MAUTIC_RUN_CRON_JOBS true

# Setting an Default database user for Mysql
ENV MAUTIC_DB_USER root

# Setting an Default database name for Mysql
ENV MAUTIC_DB_NAME mautic

# Setting PHP properties
ENV PHP_INI_DATE_TIMEZONE='UTC' \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_UPLOAD=512M \
    PHP_MAX_EXECUTION_TIME=300

ENV REQUIREMENTS_RUNTIME \
    imagemagick \
    cron \
    libzip4

ENV REQUIREMENTS_BUILD \
#    ca-certificates \
#    build-essential \
    libc-client-dev \
    libkrb5-dev \
    libfreetype6-dev \
    libpng-dev \
    libicu-dev \
    libjpeg-dev \
    unzip \
    libonig-dev \
    libcurl4-gnutls-dev \
    libzip-dev

ENV PHP_EXT_LIST \
    imap \
    intl \
    mbstring \
    mysqli \
    curl \
    pdo_mysql \
    zip \
    opcache \
    gd

# Install PHP extensions
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install --no-install-recommends -y \
    $REQUIREMENTS_RUNTIME \
    $REQUIREMENTS_BUILD \
#    software-properties-common \
#    git \
#    htop \
#    wget \
#    dos2unix \
#    curl \
#    sudo \
#    libmcrypt-dev \
#    libssl-dev \
#    libxml2-dev \
#    libmagickwand-dev \
#    libgif-dev \
#    libtiff-dev \
#    libz-dev \
#    libpq-dev \
#    imagemagick \
#    graphicsmagick \
#    libwebp-dev \
#    libjpeg62-turbo-dev \
#    libxpm-dev \
#    libaprutil1-dev \
#    nano \
#    mariadb-client \

 && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
 && docker-php-ext-configure gd --with-freetype=/usr/lib --with-jpeg=/usr/lib \
 && docker-php-ext-configure opcache --enable-opcache \
 && docker-php-ext-install ${PHP_EXT_LIST} \
 && docker-php-ext-enable ${PHP_EXT_LIST} \

# Download package and extract to web volume
 && curl -o mautic.zip -SL https://github.com/mautic/mautic/releases/download/${MAUTIC_VERSION}/${MAUTIC_VERSION}.zip \
 && echo "$MAUTIC_SHA1 *mautic.zip" | sha1sum -c - \
 && mkdir /usr/src/mautic \
 && unzip mautic.zip -d /usr/src/mautic \
 && rm mautic.zip \
 && chown -R www-data:www-data /usr/src/mautic \

 && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $REQUIREMENTS_BUILD \
 && rm -rf /var/lib/apt/lists/* \
 && rm /etc/cron.daily/*

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Define Mautic volume to persist data
VOLUME /var/www/html

# Define session store as volume - performance
VOLUME /tmp

# Copy init scripts and custom .htaccess
COPY docker-entrypoint.sh /entrypoint.sh
COPY makeconfig.php /makeconfig.php
COPY makedb.php /makedb.php
COPY mautic.crontab /etc/cron.d/mautic
RUN chmod 644 /etc/cron.d/mautic

# Enable Apache Rewrite Module
RUN a2enmod rewrite

# Apply necessary permissions
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
