#!/bin/bash
# exit when any command fails(disabled for now)
# set -e

# Usage:
# -o is output dir so is mandatory
# -v is folowed by the volume names comma seperated without spaces
# -p is followed by the prefix of volumes you want to backup
# eg1. ./backup_budibase_volumes.sh -v 'mysql_data,redis_data' -o '/tmp/backup'
# eg2. ./backup_budibase_volumes.sh -p 'budibase' -o '/tmp/backup'

# Read command options and their values
while [ -n "$1" ]
do
case "$1" in
-v)
VOLUMES="$2"
echo "Found the -v option, with parameter value $VOLUMES"
if [ -z "$VOLUMES" ];
then
   echo "\$VOLUMES is empty"
   exit 1;
elif [[ $VOLUMES == '-p' || $VOLUMES == '-o'  ]];
then
   echo "\$VOLUMES is empty"
   exit 1;
fi
shift ;;
-p)
VOLUME_PREFIX="$2"
echo "Found the -p option, with parameter value $VOLUME_PREFIX"
if [ -z "$VOLUME_PREFIX" ];
then
   echo "\$VOLUME_PREFIX is empty"
   exit 1;
elif [[ $VOLUME_PREFIX == '-v' || $VOLUME_PREFIX == '-o'  ]];
then
   echo "\$VOLUME_PREFIX is empty"
   exit 1;
fi
shift ;;
-o)
OUTPUT_DIR="$2"
echo "Found the -o option, with parameter value $OUTPUT_DIR"
if [ -z "$OUTPUT_DIR" ]
then
   echo "\$OUTPUT_DIR is empty"
   exit 1;
elif [[ $OUTPUT_DIR == '-v' || $OUTPUT_DIR == '-p'  ]];
then
   echo "\$OUTPUT_DIR is empty"
   exit 1;
fi
shift ;;
*) echo "$1 is not an option" 
   exit 1;;
esac
shift
done


function backup_volumes_from_comma_sep_string_list() {
  echo "Backup user specified docker volumes"
  IFS=', ' read -r -a dockervolumesarray <<< "$VOLUMES"

  for vol in "${dockervolumesarray[@]}"
  do
      echo "Backing up docker volume: ${vol} at: ${BACKUP_DIR}";
    ./backup_docker_volume.sh ${vol} ${BACKUP_DIR};
  done
}

function backup_all_volumes_with_prefix() {
  echo "Backup all docker volumes with user specified prefix ${VOLUME_PREFIX}"
  docker volume ls --format '{{.Name}}'| grep ^${VOLUME_PREFIX} | while read -r vol ; do
    echo "Backing up docker volume: ${vol} at: ${BACKUP_DIR}";
    ./backup_docker_volume.sh ${vol} ${BACKUP_DIR};
  done
}

function create_volume_backup_directory() {
  echo "Creating backup directory"
  if [ ! -d "${OUTPUT_DIR}" ] ; then
     echo "> Error: output directory doesn't exist at '${OUTPUT_DIR}'"
     exit 1
  fi
  echo "Creating backup path $BACKUP_DIR"
  mkdir -p ${BACKUP_DIR}
}

DATE=$(date +%Y%m%d)
DATETIME=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$OUTPUT_DIR/$DATE/$DATETIME-docker_volumes_backup"

./stop_budi.sh

create_volume_backup_directory

backup_volumes_from_comma_sep_string_list

backup_all_volumes_with_prefix

./start_budi_with__minus_d_option.sh
