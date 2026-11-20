# Stage 1: production dependencies only (PHPUnit never reaches the runtime image).
FROM composer:2 AS vendor
WORKDIR /app
COPY app/composer.json app/composer.lock ./
COPY app/src ./src
RUN composer install --no-dev --prefer-dist --no-progress --optimize-autoloader --no-scripts

# Stage 2: runtime image.
FROM php:8.3-fpm-alpine

# pdo_mysql is needed to talk to Cloud SQL (MySQL).
RUN docker-php-ext-install pdo_mysql

# Pool settings (see the file for why each line matters).
COPY docker/php-fpm/zzz-app.conf /usr/local/etc/php-fpm.d/zzz-app.conf

WORKDIR /var/www/html
COPY app/ .
COPY --from=vendor /app/vendor ./vendor

USER www-data
EXPOSE 9000