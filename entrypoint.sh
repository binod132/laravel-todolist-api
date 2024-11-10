#!/bin/sh

# Start PHP-FPM in the background
php-fpm &

# Wait for PHP-FPM to start
sleep 5

# Check and generate the encryption key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating Laravel encryption key..."
    php artisan key:generate --force
fi

# Generate Passport keys if they do not exist
if [ ! -f /var/www/storage/oauth-private.key ]; then
    echo "Generating Passport keys..."
    php artisan passport:keys
else
    echo "Passport keys already exist."
fi

# Bring PHP-FPM to the foreground to keep the container running
wait
