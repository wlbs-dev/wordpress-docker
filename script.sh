#!/bin/bash
set -e

# Load environment variables from .env file
source .env

# Wait for MySQL
until mysqladmin ping -h $WORDPRESS_DB_HOST -P 3306 -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD; do
    echo 'waiting for mysqld to be connectable...'
    sleep 2
done

# Define variables
WORK_DIR=${WORK_DIR}
WP_CONFIG_FILE="$WORK_DIR/wp-config.php"
WP_CLI_YML_FILE="$WORK_DIR/wp-cli.yml"
DB_USER=$WORDPRESS_DB_USER
DB_PASS=$WORDPRESS_DB_PASSWORD
DB_NAME=$WORDPRESS_DB_NAME
DB_HOST=$WORDPRESS_DB_HOST

# Check if wp-config.php exists
if [ ! -f $WP_CONFIG_FILE ]; then
    echo "wp-config.php not found, resetting db..."
    cp /root/wp-config.php $WP_CONFIG_FILE
    cp /root/wp-cli.yml $WP_CLI_YML_FILE
    chown -R www-data:www-data $WORK_DIR
    chmod -R 777 $WORK_DIR
    
    # Backup current DB to a file
    wp db export /root/old_db.sql --allow-root --path=$WORK_DIR

    wp db reset --yes --allow-root --path=$WORK_DIR

    # Import DB from sql file
    wp db import /root/backup.sql --allow-root --path=$WORK_DIR

    # Change site paths
    TARGET_URL=$URL_TESTING
    if [ "$IS_PROD" = "true" ]; then
        TARGET_URL=$URL_PROD
    fi
    
    wp search-replace $URL1_TO_REPLACE $TARGET_URL --allow-root --all-tables --path=$WORK_DIR
    wp search-replace $URL2_TO_REPLACE $TARGET_URL --allow-root --all-tables --path=$WORK_DIR
    wp search-replace $URL3_TO_REPLACE $TARGET_URL --allow-root --all-tables --path=$WORK_DIR
    wp search-replace $URL4_TO_REPLACE $TARGET_URL --allow-root --all-tables --path=$WORK_DIR
    if [ "$IS_PROD" = "true" ]; then
        wp search-replace 'http://' 'https://' --allow-root --all-tables --path=$WORK_DIR
    fi

    wp theme activate $BACKUP_THEME_NAME --allow-root --path=$WORK_DIR
    wp theme activate $THEME_NAME --allow-root --path=$WORK_DIR
    wp rewrite flush --hard --allow-root --path=$WORK_DIR

    mysql -h $DB_HOST -P 3306 -u $DB_USER -p$DB_PASS -D $DB_NAME <<EOF
UPDATE wp_options SET option_value='$TARGET_URL' WHERE option_name='home';
UPDATE wp_options SET option_value='$TARGET_URL' WHERE option_name='siteurl';
EOF
fi

chown -R www-data:www-data $WORK_DIR
chmod -R 777 $WORK_DIR

set +e
# Remove object cache
rm $WORK_DIR/wp-content/object-cache.php

# for ssh ownership and security
chown -R $USER:$USER /root/.ssh
chmod 700 /root/.ssh
