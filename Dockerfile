FROM php:8.1-apache-bullseye
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update && apt-get install -y \
    # Tools
    vim git curl cron wget zip unzip \
    # Others
    acl \
    apt-transport-https \
    build-essential \
    ca-certificates \
    gnupg \
    logrotate \
    lsb-release \
    make \
    mariadb-client \
    nodejs \
    openssl \
    libonig-dev \
    pkg-config \
    software-properties-common \
    # Remove apt cache from layer
    && rm -rf /var/lib/apt/lists/*

# auto install dependencies and remove libs after installing ext: https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions iconv ldap opcache xml intl pdo_mysql xsl curl json zip bcmath mbstring exif fileinfo dom gd calendar

RUN apt-get purge -y --auto-remove
RUN a2enmod rewrite

# create TMP dir
RUN mkdir -p /tmp/uploads/ && chmod +w -R /tmp/

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /home/.composer
RUN mkdir -p /home/.composer

# Apache config files
RUN ln -sf /dev/stdout /var/log/apache2/access.log && ln -sf /dev/stderr /var/log/apache2/error.log

# PHP config files
ADD docker/001-website.conf /etc/apache2/sites-enabled/000-default.conf
ADD docker/custom-php.ini /usr/local/etc/php/conf.d/custom.ini

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN set -x; \
    groupmod -g $GROUP_ID www-data && \
    usermod -u $USER_ID www-data && \
    chown -R www-data:www-data /home/.composer

WORKDIR /var/www/website

CMD apachectl -D FOREGROUND



