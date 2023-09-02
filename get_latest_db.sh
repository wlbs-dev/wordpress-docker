source .env
aws s3 ls "s3://${S3_BACKUP_LOCATION}/" | grep "backup_" | awk '{print $4}' | sort -r | head -n 1
