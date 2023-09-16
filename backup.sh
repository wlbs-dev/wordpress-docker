#!/bin/sh
set -e

# Cleanup function to keep only one backup per day for other days and delete the rest
cleanup_old_backups() {
  echo "Starting cleanup..."
  two_days_ago=$(date -d @$(( $(date -u +%s) - 172800 )) +%Y%m%d)
  echo "Two days ago: $two_days_ago"
  
  # Debug print
  echo "Listing all backups..."
  # try this 3 times before failing
  aws s3 ls s3://${S3_BUCKET}/database_backups/ || aws s3 ls s3://${S3_BUCKET}/database_backups/ || aws s3 ls s3://${S3_BUCKET}/database_backups/
  
  # Existing logic
  for backup in $(aws s3 ls s3://${S3_BUCKET}/database_backups/ | awk '{print $4}' | sort); do
    backup_date=$(echo $backup | awk -F'_' '{print substr($3,1,8)}')
    echo "Checking backup: $backup with date: $backup_date"
    if [ "$backup_date" -le "$two_days_ago" ]; then
      echo "Deleting old backup: $backup"
      # if delete fails, try again 1 more time otherwise skip
      aws s3 rm s3://${S3_BUCKET}/database_backups/$backup ||
      aws s3 rm s3://${S3_BUCKET}/database_backups/$backup || echo "Failed to delete backup: $backup"

    fi
  done
  
  echo "Cleanup complete."
}

# Call cleanup function
cleanup_old_backups

# Check if backup.sql exists, if not, fetch the latest from S3 based on naming convention
if [ ! -f /root/backups/backup.sql ]; then
  echo "backup.sql does not exist. Fetching latest from S3..."
  echo "checking location s3://${S3_BUCKET}/database_backups/"
  aws s3 ls s3://${S3_BUCKET}/database_backups/
  latest_backup=$(aws s3 ls s3://${S3_BUCKET}/database_backups/ | sort | tail -n 1 | awk '{print $4}')
  echo "Latest backup: ${latest_backup}"
  if [ ! -z "$latest_backup" ]; then
    echo "Downloading latest backup from S3..."
    aws s3 cp s3://${S3_BUCKET}/database_backups/${latest_backup} /root/backups/backup.sql
  else
    echo "No backups found in S3. Exiting."
    exit 1
  fi
fi

# Wait for MySQL to be connectable
until mysqladmin ping -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD"; do
  echo 'Waiting for MySQL to be connectable...'
  sleep 2
done

# setting IST
export TZ=Asia/Kolkata

# Load environment variables from .env file
if [ -f /.env ]; then
  source /.env
else
  echo "Error: .env file not found."
  exit 1
fi

# Create the /signal directory if it doesn't exist
mkdir -p /signal

# Set 777 permissions for the /signal directory
chmod 777 /signal

# Create backup script for selected tables
cat <<EOF > /run_selected_backup.sh
#!/bin/sh
source /.env
echo "Running selected tables backup script..."
date_time=\$(date +"%Y%m%d%H%M%S")

# Your regex pattern for table names
pattern=".*order.*"

# Get a list of tables matching the pattern from the database
tables=\$(mysql -h \$MYSQL_HOST -P \$MYSQL_PORT -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE -N -e "SELECT table_name FROM information_schema.tables WHERE table_name REGEXP '\$pattern'")

# Use mysqldump to dump the selected tables
mysqldump -h \$MYSQL_HOST -P \$MYSQL_PORT -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE \$tables > /db_backup/tables_dump.sql

aws s3 cp /db_backup/tables_dump.sql s3://\$S3_BUCKET/orders/tables_dump_\$date_time.sql
EOF
chmod +x /run_selected_backup.sh

# Create backup script for entire database
cat <<EOF > /run_full_backup.sh
#!/bin/sh
source /.env
echo "Running full database backup script..."
date_time=\$(date +"%Y%m%d%H%M%S")

mysqldump -h \$MYSQL_HOST -P \$MYSQL_PORT -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE > /db_backup/full_dump.sql

aws s3 cp /db_backup/full_dump.sql s3://\$S3_BUCKET/database_backups/full_dump_\$date_time.sql
EOF
chmod +x /run_full_backup.sh

# Watch the /signal directory for any new files named 'backup_signal'
inotifywait -m /signal -e create --format '%w%f' | while read file; do
  if [ "$file" = "/signal/backup_signal" ]; then
    echo "Backup signal file found. Running selected tables backup script..."
    /run_selected_backup.sh
    rm -f /signal/backup_signal
  fi
done &

while true; do
  echo "Sleeping for ${FULL_BACKUP_INTERVAL} seconds before running full database backup..."
  sleep ${FULL_BACKUP_INTERVAL}
  echo "Running full database backup..."
  /run_full_backup.sh
done
