# Composer image
FROM composer:1.9.3 AS composer

RUN rm -rf /var/www && mkdir /var/www

WORKDIR /var/www

COPY composer.* /var/www/

RUN composer self-update

RUN set -xe \
  && composer install --no-scripts --no-suggest --no-interaction --prefer-dist --optimize-autoloader

COPY . /var/www

RUN composer dump-autoload --optimize --classmap-authoritative

# PHP image
FROM php:7.4.5-fpm AS web

WORKDIR /var/www

ARG UNAME=developer
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

COPY . /var/www
COPY --from=composer /var/www/vendor /var/www/vendor
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY ./docker/web/php.ini /usr/local/etc/php/php.ini

RUN apt-get update && apt-get install -y \
    zlib1g-dev libzip-dev libpq-dev libxml2-dev libicu-dev g++ git unzip jq \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo pdo_pgsql

RUN pecl install apcu \
    && pecl install apcu_bc-1.0.5 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

RUN chmod +x /var/www/bin/console
RUN chmod +x /usr/bin/composer

RUN rm -rf /var/www/var \
    && mkdir -p /var/www/var

RUN chown -R developer:developer /var/www/vendor

USER $UNAME

EXPOSE 9000