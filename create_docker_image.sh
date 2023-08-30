source .env
docker build --build-arg WORK_DIR=${WORK_DIR} --build-arg EXPOSE_PORT=${EXPOSE_PORT} -t $DOCKER_NAME .
# In create_docker_image.sh, add this line to save the image to a tar file
docker save -o ${DOCKER_NAME}.tar $DOCKER_NAME
cd ..
docker load -i ./${DOCKER_NAME}/${DOCKER_NAME}.tar
cd ${DOCKER_NAME}