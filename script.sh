#!/bin/bash
set -e

# Load environment variables from .env file
source .env

cd ${WORK_DIR}

# Wait for MySQL
until mysqladmin ping -h $WORDPRESS_DB_HOST -P 3306 -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD; do
    echo 'waiting for mysqld to be connectable...'
    sleep 2
done

# Check if wp-config.php exists
if [ ! -f ${WORK_DIR}/wp-config.php ]; then
    echo "wp-config.php not found, resetting db..."
    cp /root/wp-config.php ${WORK_DIR}/wp-config.php
    cp /root/wp-cli.yml ${WORK_DIR}/wp-cli.yml
    chown -R www-data:www-data ${WORK_DIR}
    chmod -R 777 ${WORK_DIR}
    # if $DONT_USE_BACKUP=true
    if [ "$DONT_USE_BACKUP" = true ]; then
        echo "DONT_USE_BACKUP=true, skipping db import..."
        wp core install --url=$URL --title=$TITLE --admin_user=$ADMIN_USER --admin_password=$ADMIN_PASSWORD --admin_email=$ADMIN_EMAIL --allow-root
        wp rewrite structure --allow-root
    else
        echo "DONT_USE_BACKUP=false, importing db..."
        # Backup current DB to a file
        wp db export /root/old_old_db.sql --allow-root 

        wp db reset --yes --allow-root 

        # Import DB from sql file
        wp db import /root/backup.sql --allow-root 

        # Change site paths
        wp search-replace $URL1_TO_REPLACE $URL --allow-root --all-tables 
        wp search-replace $URL2_TO_REPLACE $URL --allow-root --all-tables 
        wp search-replace $URL3_TO_REPLACE $URL --allow-root --all-tables 
        wp search-replace $URL4_TO_REPLACE $URL --allow-root --all-tables 

        wp search-replace 'http://' 'https://' --allow-root --all-tables 
    fi

    wp theme activate $BACKUP_THEME_NAME --allow-root 
    wp theme activate $THEME_NAME --allow-root 
    wp rewrite flush --hard --allow-root 

    mysql -h $WORDPRESS_DB_HOST -P 3306 -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -D $WORDPRESS_DB_NAME <<EOF
UPDATE ${TABLE_PREFIX}options SET option_value='$URL' WHERE option_name='home';
UPDATE ${TABLE_PREFIX}options SET option_value='$URL' WHERE option_name='siteurl';
EOF
fi

chown -R www-data:www-data ${WORK_DIR}
chmod -R 777 ${WORK_DIR}

set +e
# Remove object cache
rm ${WORK_DIR}/wp-content/object-cache.php

# for ssh ownership and security
chown -R $USER:$USER /root/.ssh
chmod 700 /root/.ssh
