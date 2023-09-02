SERVICE_NAME="wordpress"
FULL_CONTAINER_ID=$(docker compose ps -q $SERVICE_NAME)
docker cp $FULL_CONTAINER_ID:/etc/ssl/certs/apache-selfsigned.crt ./apache-selfsigned.crt
