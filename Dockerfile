# Use the official PHP and Apache base image
FROM php:7.4-apache

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Install required PHP extensions and other dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) intl pdo pdo_pgsql gd

# Download and extract MediaWiki 1.40.1
RUN curl -O https://releases.wikimedia.org/mediawiki/1.40/mediawiki-1.40.1.tar.gz \
    && tar -xzvf mediawiki-1.40.1.tar.gz --strip-components=1 \
    && rm mediawiki-1.40.1.tar.gz

# Set the required permissions for MediaWiki
RUN chown -R www-data:www-data /var/www/html

# Enable mod_rewrite for Apache
RUN a2enmod rewrite

# Copy the default Apache configuration
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Expose port 80 for the web server
EXPOSE 80

# Start the Apache web server
CMD ["apache2-foreground"]
