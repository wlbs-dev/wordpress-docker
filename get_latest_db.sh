source .env
# if any error happens, exit
set -e
# ask user if they want local or remote backup
DATE=$(date +"%Y_%m_%d_%H_%M_%S")
read -p "Do you want to get local or remote backup? (l/r): " -n 1 -r
echo    # Move to a new line
if [[ $REPLY =~ ^[Ll]$ ]]; then
    # get latest local backup
    LATEST_FILE=$(aws s3 ls "s3://${S3_BACKUP_LOCATION}/" | grep "local_backup_" | awk '{print $4}' | sort -r | head -n 1)
else
    # get latest remote backup
    LATEST_FILE=$(aws s3 ls "s3://${S3_BACKUP_LOCATION}/" | grep "remote_backup_" | awk '{print $4}' | sort -r | head -n 1)
fi

# if $LATEST_FILE is empty, give error
if [ -z "$LATEST_FILE" ]; then
    echo "No remote backup found."
    exit 1
fi

if [[ $URL == *"localhost"* ]]; then
    mv backup.sql backup_old_${DATE}.sql
    # upload to s3
    aws s3 cp backup_old_${DATE}.sql "s3://${S3_BACKUP_LOCATION}/old_local_backup_${DATE}.sql"
else
    mv backup.sql backup_old_${DATE}.sql
    # upload to s3
    aws s3 cp backup_old_${DATE}.sql "s3://${S3_BACKUP_LOCATION}/old_remote_backup_${DATE}.sql"
fi

aws s3 cp "s3://${S3_BACKUP_LOCATION}/${LATEST_FILE}" backup.sql