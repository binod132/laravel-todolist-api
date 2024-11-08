#!/bin/sh

# Start PHP-FPM in the background
php-fpm &

# Wait for PHP-FPM to start
sleep 5

# Run the artisan command to generate passport keys
if [ ! -f storage/oauth-private.key ]; then
    echo "Generating Passport keys..."
    php artisan passport:keys
else
    echo "Passport keys already exist."
fi

# Bring PHP-FPM to the foreground
wait
