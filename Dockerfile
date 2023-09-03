# Composer image
FROM composer:latest AS composer

RUN rm -rf /var/www && mkdir /var/www

WORKDIR /var/www

COPY composer.* /var/www/

RUN composer self-update

RUN set -xe \
  && composer install --no-scripts --no-interaction --prefer-dist --optimize-autoloader

COPY . /var/www

RUN composer dump-autoload --optimize --classmap-authoritative

# PHP image
FROM php:8.2-fpm AS web

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
    gnupg curl zlib1g-dev libzip-dev libpq-dev libxml2-dev libicu-dev g++ git unzip jq \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo pdo_pgsql

RUN pecl install apcu
RUN docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini

RUN chmod +x /var/www/bin/console
RUN chmod +x /usr/bin/composer

RUN rm -rf /var/www/var \
    && mkdir -p /var/www/var \

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

RUN chown -R developer:developer /var/www/vendor

USER $UNAME

EXPOSE 9000