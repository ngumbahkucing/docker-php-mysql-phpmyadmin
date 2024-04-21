FROM php:7.4-apache
RUN apt-get update 
#RUN apt-get upgrade -y     #enable this line to upgrade packages
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install calendar

RUN apt-get install -y \
    zlib1g-dev \
    libpng-dev

RUN docker-php-ext-install gd

COPY $PWD/etc/php/php.ini /usr/local/etc/php
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
