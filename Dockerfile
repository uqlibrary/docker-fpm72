FROM uqlibrary/alpine:3.8

ENV COMPOSER_VERSION=1.6.5
ENV XDEBUG_VERSION=2.7.0alpha1
ENV BUILD_DEPS autoconf make g++ gcc groff less file re2c

COPY ./fs/docker-entrypoint.sh /usr/sbin/docker-entrypoint.sh
COPY ./fs/newrelic-install.sh /usr/sbin/newrelic-install.sh

RUN apk add --upgrade --no-cache \
    # Required deps
    php7 php7-ctype php7-curl php7-json php7-mysqli php7-dom php7-sockets \
    php7-mbstring php7-opcache php7-openssl php7-pdo_mysql php7-pdo_sqlite \
    php7-xmlwriter php7-phar php7-session php7-xml php7-mcrypt \
    php7-zip php7-zlib php7-fpm php7-dev php7-pear php7-memcached php7-soap \
    php7-simplexml php7-tokenizer php7-gd php7-ldap php7-iconv php7-xmlreader php7-fileinfo git \
    #
    # Build deps
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    #
    # XDebug
    && cd /tmp && wget https://xdebug.org/files/xdebug-${XDEBUG_VERSION}.tgz \
    && tar -zxvf xdebug-${XDEBUG_VERSION}.tgz \
    && cd xdebug-${XDEBUG_VERSION} && phpize \
    && ./configure --enable-xdebug && make && make install \
    && cd \
    && rm -rf /tmp/* \
    #
    # Composer
    && curl -sS https://getcomposer.org/installer | php7 -- --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && composer global require "hirak/prestissimo:0.3.7" \
    #
    # Remove build deps
    && rm -rf /var/cache/apk/* \
    && apk del --purge .build-deps \
    #
    # Make scripts executable
    && chmod +x /usr/sbin/docker-entrypoint.sh \
    && chmod +x /usr/sbin/newrelic-install.sh

ADD fs /

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000

WORKDIR /app
