#!/bin/sh
set -e

# Wait until backup.sql is available
until [ -f /root/backup.sql ]; do
  echo 'Waiting for backup.sql to be available...'
  sleep 2
done

echo 'backup.sql is available. Starting MySQL...'
