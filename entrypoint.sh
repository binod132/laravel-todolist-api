#!/bin/sh

# Start PHP-FPM in the background
php-fpm &

# Wait for PHP-FPM to start
sleep 5

# Check if application key exists in .env file (to avoid unnecessary key generation)
if ! grep -q 'APP_KEY=' /var/www/.env; then
    echo "Generating application key..."
    php artisan key:generate --force
else
    echo "Application key already exists."
fi

# Run the artisan command to generate passport keys if they don't exist
if [ ! -f /var/www/storage/oauth-private.key ]; then
    echo "Generating Passport keys..."
    php artisan passport:keys
else
    echo "Passport keys already exist."
fi

# Bring PHP-FPM to the foreground
wait
