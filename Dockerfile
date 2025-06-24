# Use official PHP 8.2-fpm image as base
FROM php:8.2-fpm

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    unzip \
    zip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    openssh-server \
    supervisor

RUN docker-php-ext-install pdo pdo_mysql zip

# Copy Laravel code into container
COPY . /var/www/html

WORKDIR /var/www/html

# Setup permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Copy nginx config file
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy supervisord config to run php-fpm, nginx, sshd
COPY ./supervisord.conf /etc/supervisord.conf
# Install dependencies for Composer
RUN apt-get update && apt-get install -y curl unzip git php-cli php-mbstring php-zip php-curl php-xml php-bcmath

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Verify composer is installed
RUN composer --version
# Expose ports
EXPOSE 8080 22

# Start supervisord to run all services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
