source .env
docker build --build-arg WORK_DIR=${WORK_DIR} --build-arg EXPOSE_PORT=${EXPOSE_PORT} -t $DOCKER_NAME .
