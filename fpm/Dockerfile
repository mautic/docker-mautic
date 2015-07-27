FROM php:5.6-fpm
MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Install PHP extensions
RUN apt-get update && apt-get install -y libicu-dev libmcrypt-dev zip unzip
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install intl mbstring mcrypt mysqli pdo pdo_mysql

VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 1.1.3
ENV MAUTIC_UPSTREAM_VERSION 1.1.3
ENV MAUTIC_SHA1 77e4fe2438b3efac8a26f4f8c6c216a89fac1337

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

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
