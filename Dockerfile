FROM php:7.4-apache
RUN apt-get update && apt-get upgrade -y
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install calendar

COPY $PWD/etc/php/php.ini /usr/local/etc/php

EXPOSE 80
