# syntax=docker/dockerfile:1
ARG MAUTIC_IMAGE=mautic/mautic:7.2.1-apache

FROM ${MAUTIC_IMAGE} AS builder

# Composer's post-update-cmd runs npm ci and generates frontend assets.
# Keep Node/npm and build dependencies in this stage only.
RUN apt-get update && \
    apt-get install --no-install-recommends -y build-essential ca-certificates curl && \
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install --no-install-recommends -y nodejs && \
    npm install -g npm@latest

WORKDIR /var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000

COPY ./plugins/ /var/www/html/docroot/plugins/

# Optional Composer package, for example vendor/plugin:^1.0.
ARG COMPOSER_PACKAGE
RUN if [ -n "$COMPOSER_PACKAGE" ]; then \
        composer require --no-interaction "$COMPOSER_PACKAGE"; \
    fi

# Add any plugin-specific frontend build commands above this cleanup step.
RUN php bin/console mautic:assets:generate && \
    rm -rf var/cache/js && \
    find node_modules -mindepth 1 -maxdepth 1 -not \( -name 'jquery' -or -name 'vimeo-froogaloop2' \) -exec rm -rf {} +

FROM ${MAUTIC_IMAGE}

COPY --from=builder --chown=www-data:www-data /var/www/html/ /var/www/html/
RUN cd /var/www/html && php bin/console cache:clear && \
    chown -R www-data:www-data var/
