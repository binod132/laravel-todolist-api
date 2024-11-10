#!/bin/sh

# Start PHP-FPM in the background
php-fpm &

# Wait for PHP-FPM to start
sleep 5

# Check if .env file exists, create if not
if [ ! -f /var/www/.env ]; then
    echo "Creating .env file..."
    cp /var/www/.env.example /var/www/.env

    # Generate the Laravel application key and store it in .env
    echo "Generating application key..."
    php artisan key:generate --force
else
    echo ".env file already exists."
fi

# Generate Passport
