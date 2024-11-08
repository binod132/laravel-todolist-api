# Dockerfile for Nginx
FROM nginx:alpine

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom Nginx configuration
COPY ./nginx.conf.example /etc/nginx/conf.d/default.conf

# Copy the Laravel public folder from the Laravel image build
COPY ./public /var/www/public

# Set permissions for the Nginx user
COPY . /var/www
RUN chown -R nginx:nginx /var/www/public

# Expose port 8080
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
