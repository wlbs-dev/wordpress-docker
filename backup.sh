#!/bin/sh
set -e

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

# Create backup script
cat <<EOF > /run_backup.sh
#!/bin/sh
source /.env
echo "Running backup script..."
date_time=\$(date +"%Y%m%d%H%M%S")

# Your regex pattern for table names
pattern=".*orders.*"

# Get a list of tables matching the pattern from the database
tables=\$(mysql -h \$MYSQL_HOST -P \$MYSQL_PORT -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE -N -e "SELECT table_name FROM information_schema.tables WHERE table_name REGEXP '\$pattern'")

# Use mysqldump to dump the selected tables
mysqldump -h \$MYSQL_HOST -P \$MYSQL_PORT -u \$MYSQL_USER -p\$MYSQL_PASSWORD \$MYSQL_DATABASE \$tables > /db_backup/tables_dump.sql

aws s3 cp /db_backup/tables_dump.sql s3://\$S3_BUCKET/tables_dump_\$date_time.sql
EOF

# Make it executable
chmod +x /run_backup.sh

# Loop to check for signal file
# Watch the /signal directory for any new files named 'backup_signal'
inotifywait -m /signal -e create --format '%w%f' | while read file; do
  if [ "$file" = "/signal/backup_signal" ]; then
    echo "Backup signal file found. Running backup script..."
    /run_backup.sh
    rm -f /signal/backup_signal
  fi
done
