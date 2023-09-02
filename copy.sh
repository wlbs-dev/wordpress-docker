#!/bin/bash

source .env

# Container name or ID as defined in docker-compose.yml
SERVICE_NAME="wordpress"

if docker compose ps | grep -q "$SERVICE_NAME"; then
    echo "$SERVICE_NAME service is running."
else
    echo "$SERVICE_NAME service is not running."
    exit 1
fi

# Run the command
docker compose exec -T $SERVICE_NAME bash -c "cd /var/www/html/mysite/ && wp db export /root/old_old_db.sql --allow-root"

echo "Command has been executed."

# GET DATE
DATE=$(date +"%Y_%m_%d_%H_%M_%S")
# Source path inside the container
SOURCE_PATH="/root/old_old_db.sql"

# Destination path on your host machine
DEST_PATH="backup_docker_${DATE}.sql"your_default_s3_folder

# Get the full container ID
FULL_CONTAINER_ID=$(docker compose ps -q $SERVICE_NAME)

# Copy the file
docker cp "$FULL_CONTAINER_ID:$SOURCE_PATH" "$DEST_PATH"

echo "File copied successfully."

# rename file backup.sql to backup_old.sql
mv backup.sql backup_old_${DATE}.sql
mv ${DEST_PATH} backup.sql

echo "File renamed successfully."

# Ask user if they want to push backup to S3
read -p "Do you want to push backup to S3? (y/n): " -n 1 -r
echo    # Move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Folder should be set in environment variable
    # Upload to S3 using aws-cli
    aws s3 cp backup.sql "s3://${S3_BACKUP_LOCATION}/backup_${DATE}.sql"
    echo "File uploaded to S3 successfully."
fi