#!/bin/sh

# Start PHP-FPM in the background
php-fpm &

# Wait for PHP-FPM to start
sleep 5

# Check if APP_KEY in .env is empty or missing
if grep -q '^APP_KEY=$' /var/www/.env; then
    echo "APP_KEY is empty. Generating application key..."
    php artisan key:generate --force
else
    echo "APP_KEY already set."
fi

# # Run the artisan command to generate passport keys if they don't exist
# if [ ! -f /var/www/storage/oauth-private.key ]; then
#     echo "Generating Passport keys..."
#     php artisan passport:keys
# else
#     echo "Passport keys already exist."
# fi

# Bring PHP-FPM to the foreground
wait
