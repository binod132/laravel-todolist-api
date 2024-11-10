# Stage 1: Use pre-built base image for build environment 
FROM hmis-repo.midashealthservices.com.np/php:8.1 AS builder 
 
LABEL maintainer="Binod Adhikari" \ 
      email="binod.adhikari@midastechnologies.com"       
WORKDIR /var/www 
 
# Copy composer files and install dependencies 
COPY composer.lock composer.json /var/www/ 
RUN composer update --no-dev --prefer-dist --optimize-autoloader --ignore-platform-reqs

# Check Vendor folder
RUN pwd && ls -al /var/www/vendor
# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
 
# Stage 2: Production environment 
FROM php:8.1-fpm 
 
WORKDIR /var/www 
 
# Copy files from builder stage
COPY --from=builder /var/www/vendor /var/www/vendor
COPY --from=builder /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh

# Additional dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpq-dev \
    libonig-dev \
    libzip-dev \
    libwebp-dev \
    net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
 
# Add user for Laravel application 
RUN groupadd -g 1000 www-todo 
RUN useradd -u 1000 -ms /bin/bash -g www-todo www-todo

# Set permissions
RUN chown -R www-todo:www-todo /var/www/vendor
USER www-todo

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
