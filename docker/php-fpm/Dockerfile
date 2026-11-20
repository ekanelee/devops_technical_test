FROM php:8.3-fpm-alpine

# pdo_mysql is needed to talk to Cloud SQL (MySQL).
RUN docker-php-ext-install pdo_mysql

# Pool settings (see the file for why each line matters).
COPY docker/php-fpm/zzz-app.conf /usr/local/etc/php-fpm.d/zzz-app.conf

WORKDIR /var/www/html
COPY app/ .

USER www-data
EXPOSE 9000