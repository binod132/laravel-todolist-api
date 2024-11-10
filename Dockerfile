ARG REGISTRY 
ARG BASE_IMAGE 
# Stage 1: Use pre-built base image for build environment 
FROM hmis-repo.midashealthservices.com.np/php:8.2 AS builder 
 
LABEL maintainer="Binod Adhikari" \ 
      email="binod.adhikari@midastechnologies.com"       
WORKDIR /var/www 
 
# Copy composer files and install dependencies 
COPY composer.lock composer.json /var/www/ 
# RUN composer install --no-dev --no-cache --no-scripts --prefer-dist --optimize-autoloader
# RUN composer install --no-dev --no-cache && php artisan octane:start --workers=8 --task-workers=16 --host=0.0.0.0 --max-requests=500 --port=9000
COPY --chown=www-todo:www-todo . /var/www
RUN chmod -R 775 /var/www/storage
RUN composer update --no-dev --prefer-dist --optimize-autoloader --ignore-platform-reqs

# Check Vendor folder
RUN pwd && ls -al
# Copy the application code for building 
COPY . /var/www 
# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
 
# Stage 2: Production environment 
FROM php:8.2-fpm 
 
WORKDIR /var/www 
 
# Copy installed PHP extensions from the builder stage 
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/ 
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-* /usr/local/etc/php/conf.d/ 
COPY --from=builder /var/www/vendor /var/www/vendor
COPY . /var/www  
COPY --from=builder /usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
# Install minimal runtime dependencies 
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
 
# Add user for laravel application 
RUN groupadd -g 1000 www-todo 
RUN useradd -u 1000 -ms /bin/bash -g www-todo www-todo
 
# Copy existing application directory contents 
# COPY .env.example /var/www/.env
COPY --chown=www-todo:www-todo . /var/www 
 
# Set permissions for storage directory. 
RUN chown -R www-todo:www-todo /var/www/storage 
RUN chmod -R 775 /var/www/storage 
RUN chown -R www-todo:www-todo /var/www/vendor
RUN chmod -R 775 /var/www/vendor
# Change current user to www 
USER www-todo
#CMD ["php-fpm"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]