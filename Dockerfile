ARG PHP_TAG=8.4

FROM php:${PHP_TAG}-fpm-bookworm

RUN set -xe \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libmcrypt-dev \
        libzip-dev \
        libicu-dev \
        libonig-dev \
        g++ \
        make \
        autoconf \
        pkg-config \
        git \
    && yes | pecl install -o -f mcrypt-1.0.9 \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install opcache \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl \
    && pecl download mailparse-3.1.8 && tar -xvf mailparse-3.1.8.tgz  && cd mailparse-3.1.8/ && phpize \
    && ./configure \
    && sed -i 's/#if\s!HAVE_MBSTRING/#ifndef MBFL_MBFILTER_H/' ./mailparse.c \
    && make \
    && make install \
    && cd .. && rm -rf mailparse-3.1.8 mailparse-3.1.8.tgz package.xml \
    && echo "extension=mailparse.so" > /usr/local/etc/php/conf.d/30-mailparse.ini \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && apt-get purge -y libmcrypt-dev libzip-dev libicu-dev libonig-dev gcc g++ cpp build-essential make autoconf pkg-config git; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -xe && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./laravel.ini  /usr/local/etc/php/conf.d
COPY ./xlaravel.pool.conf /usr/local/etc/php-fpm.d/

WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000
