#!/bin/sh
set -e

source .env

# Create backup script
cat <<EOF > /run_backup.sh
#!/bin/sh
date_time=\$(date +"%Y%m%d%H%M%S")
mysqldump -h\$MYSQL_HOST -u\$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE orders > /db_backup/orders_\$date_time.sql

aws s3 cp /db_backup/orders_\$date_time.sql s3://\$S3_BUCKET/orders_\$date_time.sql

EOF

# Make it executable
chmod +x /run_backup.sh

# Install MySQL client and AWS CLI
apk add --no-cache mysql-client aws-cli

# Loop to check for signal file
while true; do
  if [ -f /signal/backup_signal ]; then
    /run_backup.sh
    rm -f /signal/backup_signal
  fi
  sleep 5
done
