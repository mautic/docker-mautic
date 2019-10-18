FROM php:7.2-fpm
VOLUME /var/www/html
LABEL vendor="Mautic"
LABEL maintainer="Luiz Eduardo Oliveira Fonseca <luiz@powertic.com>"

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.15.3
ENV MAUTIC_SHA1 d6ec21376ceacd8bbb8d9ee58e81d8050a79c0b8

# By default enable cron jobs
ENV MAUTIC_RUN_CRON_JOBS true

# Setting an root user for test
ENV MAUTIC_DB_USER root
ENV MAUTIC_DB_NAME mautic
COPY . /
# Install PHP extensions
RUN apt-get update && apt-get install --no-install-recommends -y \
    cron \
    git \
    wget \
    libc-client-dev \
    libicu-dev \
    libkrb5-dev \
    libssl-dev \
    libz-dev \
    unzip \
    zip \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/cron.daily/* \
    && docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install imap intl mbstring mysqli pdo_mysql zip opcache bcmath \
    && docker-php-ext-enable imap intl mbstring mysqli pdo_mysql zip opcache bcmath \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer  \
    && curl -o mautic.zip -SL https://github.com/mautic/mautic/releases/download/${MAUTIC_VERSION}/${MAUTIC_VERSION}.zip \
	&& echo "$MAUTIC_SHA1 *mautic.zip" | sha1sum -c - \
	&& mkdir /usr/src/mautic \
	&& unzip mautic.zip -d /usr/src/mautic \
	&& rm mautic.zip \
	&& mv /usr/src/mautic /var/www/html && chown -R www-data:www-data /var/www/html/ \
	&& cp /mautic.crontab /etc/cron.d/mautic && chmod 644 /etc/cron.d/mautic \
	&& cp mautic-php.ini /usr/local/etc/php/conf.d/mautic-php.ini


# Apply necessary permissions
RUN ["chmod", "+x", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
