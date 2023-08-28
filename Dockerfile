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

# Declare ARG for work directory
ARG WORK_DIR

ARG EXPOSE_PORT

# Set the working directory using ARG
WORKDIR ${WORK_DIR}

# Expose port
EXPOSE ${EXPOSE_PORT}

# Copy the script that changes the site paths and imports the database
COPY ./script.sh /usr/local/bin
RUN chmod +x /usr/local/bin/script.sh
# Suppress message about server's fully qualified domain name
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN a2enmod ssl
# Generate a self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=IN/ST=State/L=City/O=Organization/OU=Department/CN=example.com"

# Modify the Apache SSL configuration to use the generated certificate
RUN sed -i \
    -e 's|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/ssl/certs/apache-selfsigned.crt|' \
    -e 's|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/ssl/private/apache-selfsigned.key|' \
    /etc/apache2/sites-available/default-ssl.conf

# Enable SSL module and site
RUN a2enmod ssl && \
    a2ensite default-ssl
RUN service apache2 restart

# Setting php ini upload size
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /usr/local/etc/php/php.ini

# Start Apache in the foreground and execute your script
CMD /usr/local/bin/script.sh; apache2-foreground
