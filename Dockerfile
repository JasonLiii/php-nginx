FROM php:5.6-fpm
MAINTAINER Miles <miles@ifalo.com.tw>

ENV WWW_ROOT /var/www/html
ENV PUBLIC_ROOT /var/www/html/public
ENV NGINX_VERSION 1.9.9-1~jessie
ENV PHP_HOME /usr/local/etc/php

WORKDIR ${WWW_ROOT}

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
    echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${WWW_ROOT} && mkdir -p ${PHP_HOME} && \
    chmod +x /entrypoint.sh

# Copy configurations
COPY php.ini ${PHP_HOME}/php.ini
COPY nginx /etc/nginx
COPY fpm /etc/php/fpm
COPY supervisord.conf /etc/supervisord.conf
COPY supervisor.d /etc/supervisor.d

# Install require extension
RUN apt-get update -y && apt-get install -y \
    git \
    libbz2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libpng12-dev \
    libssl-dev \
    zlib1g-dev \
    && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) bcmath bz2 gd mbstring mcrypt mysqli pdo_mysql zip && \
    pecl install mongo redis memcached && \
    echo "extension=mongo.so" > /usr/local/etc/php/conf.d/mongo.ini && \
    echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini && \
    echo "extension=memcached.so" > /usr/local/etc/php/conf.d/memcached.ini && \
    curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
    apt-get clean && rm -r /var/lib/apt/lists/*

# Export nginx ports
EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
