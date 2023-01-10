ARG PHP_VERSION
FROM php:${PHP_VERSION:+$PHP_VERSION-}fpm-alpine AS fpm
LABEL maintainer="Proload-tecnologia"

# Install PHP extensions, libs and Composer
ARG PHPREDIS_CFLAGS='enable-redis-igbinary="no" enable-redis-lzf="no" enable-redis-zstd="no"'
RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
        g++ make autoconf linux-headers \
        freetype-dev \
        jpeg-dev \
        libpng-dev \
        libpq-dev \
        libwebp-dev \
        libzip-dev \
    ; \
    docker-php-ext-configure \
        gd --with-freetype --with-jpeg --with-webp \
    ; \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        exif \
        gd \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        sockets \
        zip \
    ; \
    pecl install xdebug; \
    pecl install -D "$PHPREDIS_CFLAGS" redis; \
    docker-php-ext-enable xdebug redis; \
    php -r "readfile('http://getcomposer.org/installer');" | php -- \
        --install-dir=/usr/bin/ \
        --filename=composer \
    ; \
    apk del --no-network .build-deps; \
    apk add --no-cache \
        freetype \
        libjpeg \
        libpng \
        libpq \
        libwebp \
        libzip \
    ;

# Install other software and setup shortcuts and aliases
RUN set -eux; \
    apk add --no-cache \
        acl \
        ca-certificates \
        curl \
        less \
        npm \
        openssl \
        su-exec \
        tar \
        tzdata \
    ; \
    { \
        echo "alias ll='ls -lah'"; \
        echo "alias php='user-exec php'"; \
        echo "alias composer='user-exec composer'"; \
        echo "alias tinker='env EDITOR=vi user-exec php artisan tinker'"; \
    } | tee /etc/profile.d/alias.sh;
ENV ENV="/etc/profile"
COPY ./scripts/user-exec.sh /usr/sbin/user-exec

EXPOSE 9000
CMD ["php-fpm"]
