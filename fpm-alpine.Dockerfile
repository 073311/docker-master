FROM php:8.1-fpm-alpine3.15

# Arguments defined in docker-compose.yml
ARG ievtds_DOCKERFILE_VERSION=0.1
ARG SUPPORTED_LOCALES="en_US.UTF-8"

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories

# Add Build Dependencies
RUN apk add --no-cache --virtual .build-deps  \
    zlib-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    bzip2-dev \
    zip \
    libzip-dev

# Add Production Dependencies
RUN apk add --update --no-cache \
    jpegoptim \
    pngquant \
    optipng \
    supervisor \
    nano \
    bash \
    icu-dev \
    freetype-dev \
    mysql-client

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install PHP Extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd zip intl imap xsl pgsql opcache bcmath mysqli pdo_mysql redis pcntl

# Configure Extension
RUN docker-php-ext-configure \
    opcache --enable-opcache

# Download ievtds application
RUN mkdir -p /var/www/ievtds \
    && curl -Lo /tmp/ievtds.zip 'https://ievtds.com/download.php?version=latest&utm_source=docker&utm_campaign=developers' \
    && unzip /tmp/ievtds.zip -d /var/www/html \
    && rm -f /tmp/ievtds.zip

COPY files/ievtds-php-fpm.sh /usr/local/bin/ievtds-php-fpm.sh
COPY files/html /var/www/html

# Setup Working Dir
WORKDIR /var/www/html

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/ievtds-php-fpm.sh"]
CMD ["--start"]