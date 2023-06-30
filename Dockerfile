ARG PHP_VERSION
FROM php:${PHP_VERSION}

### Diretório da aplicação
ARG APP_DIR=/var/www/app
ARG EXTERNAL_APP_DIR=./../../

### Versão da Lib do Redis para PHP
ARG REDIS_LIB_VERSION=5.3.7

### Instalação de pacotes e recursos necessários no S.O.
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    apt-utils \
    supervisor \
    zlib1g-dev \
    libzip-dev \
    unzip \
    libpng-dev \
    libpq-dev \
    libxml2-dev \
    nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Dependências recomendadas do PHP
RUN docker-php-ext-install mysqli pdo pdo_mysql pdo_pgsql pgsql session xml zip iconv simplexml pcntl gd fileinfo \
    && pecl install redis-${REDIS_LIB_VERSION} \
    && docker-php-ext-enable redis \
    && pecl install swoole \
    && docker-php-ext-enable swoole

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

### NGINX
RUN rm -rf /etc/nginx/sites-enabled/* \
    && rm -rf /etc/nginx/sites-available/*

### Arquivos de configuração
COPY --chown=www-data:www-data ./docker/supervisord/supervisord.octane.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=www-data:www-data ./docker/supervisord/conf /etc/supervisord.d/
COPY --chown=www-data:www-data ./docker/php/extra-php.ini "$PHP_INI_DIR/99_extra.ini"
COPY --chown=www-data:www-data ./docker/nginx/sites.octane.conf /etc/nginx/sites-enabled/default.conf
COPY --chown=www-data:www-data ./docker/nginx/error.html /var/www/app/error.html

### Copiando aplicação para dentro do container
WORKDIR $APP_DIR
COPY --chown=www-data:www-data . .
RUN cd $APP_DIR
RUN ls -lah composer.json

### OCTANE
RUN chown -R www-data:www-data $APP_DIR \
    && composer install --no-interaction \
    && composer require laravel/octane \
    && php artisan octane:install --server=swoole


# CRIAR USUÁRIO SUPERVISOR
# RUN useradd -ms /bin/bash supervisor
# RUN mkdir -p /var/log/supervisor
# RUN chown supervisor:supervisor /var/log/supervisor
# RUN mkdir -p /var/run
# RUN chown supervisor:www-data /var/run
# RUN chmod 777 /var/run

### HORIZON
RUN composer require laravel/horizon \
    && php artisan horizon:install

### Comandos úteis para otimização da aplicação
RUN php artisan clear-compiled \
    && php artisan optimize


### Limpeza e otimização da construção
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get autoremove -y \
    && apt-get clean

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]