#!/bin/sh
set -e

source /.env

# Create the /signal directory if it doesn't exist
mkdir -p /signal

# Set 777 permissions for the /signal directory
chmod 777 /signal

# Create backup script
cat <<EOF > /run_backup.sh
#!/bin/sh
echo "Running backup script..."
date_time=\$(date +"%Y%m%d%H%M%S")
mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} ${TABLE_PREFIX}orders > /db_backup/orders_\$date_time.sql

aws s3 cp /db_backup/orders_\$date_time.sql s3://${S3_BUCKET}/orders_\$date_time.sql
EOF

# Make it executable
chmod +x /run_backup.sh

# Loop to check for signal file
while true; do
  if [ -f /signal/backup_signal ]; then
    echo "Backup signal file found. Running backup script..."
    /run_backup.sh
    rm -f /signal/backup_signal
  fi
  echo "Sleeping for 5 seconds... Backup script will run again if signal file is found."
  sleep 5
done
