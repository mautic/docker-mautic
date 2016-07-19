FROM php:5.6-apache
MAINTAINER Michael Babker <michael.babker@mautic.org> (@mbabker)

# Enable Apache Rewrite Module
RUN a2enmod rewrite

# Install PHP extensions
RUN apt-get update && apt-get install -y libc-client-dev libicu-dev libkrb5-dev libmcrypt-dev libssl-dev unzip zip
RUN rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-imap --with-imap-ssl --with-kerberos
RUN docker-php-ext-install imap intl mbstring mcrypt mysqli pdo pdo_mysql zip

VOLUME /var/www/html

# Define Mautic version and expected SHA1 signature
ENV MAUTIC_VERSION 2.0.0
ENV MAUTIC_SHA1 42197c6ddc7e4a505e6785e1bc794b212c4d6fb1

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
RUN tar xf /usr/src/php.tar.xz \
        -C /usr/local/etc/php/ \
        --strip-components 1 \
        php-5.6.23/php.ini-production \
  && mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
  && sed -i -e "/always_populate_raw_post_data/ s/^;//" /usr/local/etc/php/php.ini

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
