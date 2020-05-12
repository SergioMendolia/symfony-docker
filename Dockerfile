FROM php:7.4-apache-buster
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -

RUN apt-get update && apt-get install -y \
    # Tools
    vim git curl cron wget zip unzip \
    # libs
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libssl-dev \
    libwebp-dev \
    libx11-6 \
    libxext6 \
    libxml2-dev \
    libxrender1 \
    libxslt-dev \
    libxslt1-dev \
    libxslt1.1 \
    libzip-dev \
    libzip4 \
    zlib1g-dev \
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
    supervisor \
    xfonts-75dpi \
    xfonts-base \
    # Remove apt cache from layer
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install -j$(nproc) iconv  opcache xml intl pdo_mysql xsl curl json zip bcmath mbstring exif fileinfo dom gd
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN apt-get purge -y --auto-remove libfreetype6-dev libcurl4-openssl-dev libicu-dev libpng-dev libssl-dev libxml2-dev libxslt-dev libfreetype6-dev libzip-dev zlib1g-dev
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



