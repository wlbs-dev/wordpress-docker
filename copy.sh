#!/bin/bash

# Container name or ID as defined in docker-compose.yml
SERVICE_NAME="wordpress"

# Run the command
docker compose exec -T $SERVICE_NAME bash -c "cd /var/www/html/mysite/ && wp db export /root/old_old_db.sql --allow-root"

echo "Command has been executed."

# GET DATE
DATE=$(date +"%Y_%m_%d_%H_%M_%S")
# Source path inside the container
SOURCE_PATH="/root/old_old_db.sql"

# Destination path on your host machine
DEST_PATH="backup_docker_${DATE}.sql"

# Get the full container ID
FULL_CONTAINER_ID=$(docker compose ps -q $SERVICE_NAME)

# Copy the file
docker cp "$FULL_CONTAINER_ID:$SOURCE_PATH" "$DEST_PATH"

echo "File copied successfully."

# rename file backup.sql to backup_old.sql
mv backup.sql backup_old_${DATE}.sql
mv ${DEST_PATH} backup.sql

echo "File renamed successfully."