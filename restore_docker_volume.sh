!/bin/bash


# command syntax ./backup_volume {volume_name} {backup_directory} {backup_file}
# if execute command in backup folder you can use ${PWD} for backup directory for convinience

# STEPS:
# 1. Validate that the docker-volume doesn't exist and that the restore file (tar.gz) exists
# 2. Start a new container that mounts the docker-volume and the restore file
# 3. Extract the content of the restore file to the docker-volume
# 4. A new container can now mount the restored docker-volume

DOCKER_RESTORE_VOLUME=$1
BACKUP_DIR=$2
RESTORE_FILE=$3
DOCKER_IMAGE=busybox

echo "Created internal parameters"
echo "Util docker image: '${DOCKER_IMAGE}'"
echo "Docker restore volume: '${DOCKER_RESTORE_VOLUME}'"
echo "Backup folder: '${BACKUP_DIR}'"
echo "Restore file: '${RESTORE_FILE}'"

function validateInput() {
    if [ ! -d "${BACKUP_DIR}" ] ; then
        echo "> Error: backup directory doesn't exist at '${BACKUP_DIR}'"
        exit 1
    fi

    if [ ! -f "${BACKUP_DIR}/${RESTORE_FILE}" ] ; then
        echo "> Error: Restore file ${RESTORE_FILE} not found at ${BACKUP_DIR}"
        exit 1
    fi

    INSPECT_VOLUME=$(docker volume inspect ${DOCKER_RESTORE_VOLUME} 2>&1)
    if [[ ! ${INSPECT_VOLUME} == *"No such volume"* ]] ; then
        echo "> Error: docker volume '${DOCKER_RESTORE_VOLUME}' already exists"
        exit 1
    fi
}

echo "> Restoring the file '${RESTORE_FILE}' to docker-volume '${DOCKER_RESTORE_VOLUME}'"
validateInput

echo "> Creating docker volume:" $(docker volume create --name ${DOCKER_RESTORE_VOLUME})

docker run --rm	\
-v ${DOCKER_RESTORE_VOLUME}:/backup-dest \
-v ${BACKUP_DIR}:/backup-src \
${DOCKER_IMAGE} \
sh -c "cd /backup-dest && tar -xzvf /backup-src/${RESTORE_FILE}"

echo "> Finished! Docker volume '${DOCKER_RESTORE_VOLUME}' is ready for use"
