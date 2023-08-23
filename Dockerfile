# Use the official WordPress image as a base
FROM wordpress:6.2.2

# Install necessary packages for WP CLI and git
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    less \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*


# Install WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Change ownership of the /var/www/html directory to the www-data user
RUN chown -R www-data:www-data /var/www/html

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Copy the script that changes the site paths and imports the database
COPY ./script.sh /usr/local/bin
RUN chmod +x /usr/local/bin/script.sh
# Suppress message about server's fully qualified domain name
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
# Setting php ini upload size
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /usr/local/etc/php/php.ini

# Start Apache in the foreground and execute your script
CMD /usr/local/bin/script.sh; apache2-foreground
