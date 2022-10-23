#!/bin/bash

# command syntax ./backup_volume {volume_name} {backup_directory}
# STEPS:
# 1. Validate that the docker-volume and backup dir exists
# 2. Start a new container that mounts the docker-volume and the backup dir
# 3. Create a "tar" of the content of the docker-volume and place it in the backup dir

DOCKER_VOLUME=$1
BACKUP_DIR=$2
#BACKUP_FILE=${DOCKER_VOLUME}-backup-$(date +%y%m%d-%H%M%S).tar.gz
BACKUP_FILE=${DOCKER_VOLUME}-backup.tar.gz
DOCKER_IMAGE=busybox

echo "Created internal parameters"
echo "Util docker image: '${DOCKER_IMAGE}'"
echo "Docker volume: '${DOCKER_VOLUME}'"
echo "Backup folder: '${BACKUP_DIR}'"
echo "Backup file: '${BACKUP_FILE}'"

function validateInput() {
    if [ ! -d "${BACKUP_DIR}" ] ; then
        echo "> Error: backup directory doesn't exist at '${BACKUP_DIR}'"
        exit 1
    fi

    INSPECT_VOLUME=$(docker volume inspect ${DOCKER_VOLUME} 2>&1)
    if [[ ${INSPECT_VOLUME} == *"No such volume"* ]] ; then
        echo "> Error: docker volume '${DOCKER_VOLUME}' not found"
        exit 1
    fi
}

validateInput

docker run --rm	\
-v ${DOCKER_VOLUME}:/backup-src \
-v ${BACKUP_DIR}:/backup-dest \
${DOCKER_IMAGE} \
sh -c "cd /backup-src && tar -czvf /backup-dest/${BACKUP_FILE} ."

echo "> Backup of docker-volume finished!"
