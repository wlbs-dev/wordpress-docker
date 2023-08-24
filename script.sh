#!/bin/bash
set -e
# Wait for MySQL
until mysqladmin ping -h db -P 3306 -u wpdbuser -pchange_me_db_password; do
    echo 'waiting for mysqld to be connectable...'
    sleep 2
done
if [ ! -f /var/www/html/mysite/wp-config.php ]; then
    echo "wp-config.php not found, resetting db..."
    cp /root/wp-config.php /var/www/html/mysite/wp-config.php
    cp /root/wp-cli.yml /var/www/html/mysite/wp-cli.yml
    chown -R www-data:www-data /var/www/html/mysite
    # change ownership of /var/www/html/mysite to 777
    chmod -R 777 /var/www/html/mysite
    # Backup current DB to a file
    wp db export /root/old_db.sql --allow-root

    wp db reset --yes --allow-root

    # Import DB from sql file
    wp db import /root/backup.sql --allow-root

    # Change site paths
    wp search-replace 'http://localhost:8000/' 'https://staging.wlbs.dev/mysite/' --allow-root --all-tables
    wp search-replace 'http://127.0.0.1:8000/' 'https://staging.wlbs.dev/mysite/' --allow-root --all-tables
    wp search-replace 'http://example.com/' 'https://staging.wlbs.dev/mysite/' --allow-root --all-tables
    wp search-replace 'https://example.com/' 'https://staging.wlbs.dev/mysite/' --allow-root --all-tables
    wp search-replace 'http://' 'https://' --allow-root --all-tables

    wp theme activate twentynineteen --allow-root

    wp theme activate mysite --allow-root

    wp rewrite flush --hard --allow-root

    mysql -h db -P 3306 -u wpdbuser -pchange_me_db_password -D wordpress <<EOF
UPDATE wp_options SET option_value='https://staging.wlbs.dev/mysite/' WHERE option_name='home';
UPDATE wp_options SET option_value='https://staging.wlbs.dev/mysite/' WHERE option_name='siteurl';
EOF
fi

chown -R www-data:www-data /var/www/html/mysite

# change permissions of /var/www/html/mysite to 777
chmod -R 777 /var/www/html/mysite

set +e
# Remove object cache
rm wp-content/object-cache.php

# for ssh ownership and security
chown -R $USER:$USER /root/.ssh
chmod 700 /root/.ssh
