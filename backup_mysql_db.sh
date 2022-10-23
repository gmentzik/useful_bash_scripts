#!/bin/bash

################################################################
################## Update below values ########################

DB_BACKUP_PATH='/opt/clics/backup/mysqldump'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='backupuser'
MYSQL_PASSWORD=''
DATABASE_NAME='new_clics3'
BACKUPS_TO_KEEP=30 ## Number of backups to keep

#################################################################
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_EXTENTION='.sql.gz'
ZIPFILE=${DATABASE_NAME}-${TIMESTAMP}${BACKUP_EXTENTION}

# SUBROUTINES
remove_failed_backup_if_exists() { 
  # removes failed backup file if exists
  echo "Check if failed backup file: $1 exists."
  if [ -f "$1" ]; then
      echo "Failed backup file found. Removing..."
      rm $1
  else
      echo " File does not exist. No removal is needed"
  fi
}


echo "*** Backup started  at ${TIMESTAMP} ***"
echo "database - ${DATABASE_NAME}"

# mysqldump user password is defined at .my.cnf file at backup user home folder.
# This is script must be executed by backup user in order to fetch password otherwise must be added at command bellow.
# By default mysqldump will lock tables during backup. Consider adding parameters --single-transaction --skip-lock-tables 
# if you don't want to block application during backup. However you must ensure that all database tables are Inno_db.
mysqldump -h ${MYSQL_HOST} \
-P ${MYSQL_PORT} \
-u ${MYSQL_USER} \
--password=${MYSQL_PASSWORD} \
-R ${DATABASE_NAME} \
--skip-extended-insert | gzip -9 > ${DB_BACKUP_PATH}/${ZIPFILE}

# gzip will be successfull even if mysqldump fails because by default pipe will keep last result
# so we need to check first if mysqldump command failed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
echo "mysqldump was successful"
else
echo "mysqldump failed"
remove_failed_backup_if_exists "${DB_BACKUP_PATH}/${ZIPFILE}"
exit 1
fi

# Check gzip (last pipe result) result
if [ $? -eq 0 ]; then
echo "Database backup file ${ZIPFILE} successfully created"
else
echo "Error found during backup"
remove_failed_backup_if_exists "${DB_BACKUP_PATH}/${ZIPFILE}"
exit 1
fi


#echo "Begining cleanup of database backup folder"
#FOUND_BACKUPS=`cd ${DB_BACKUP_PATH} && ls -l ${DATABASE_NAME}*${BACKUP_EXTENTION} | wc -l`
#echo "Set to keep the latest " ${BACKUPS_TO_KEEP} " backups"
#echo "Found ${FOUND_BACKUPS} backups"

#if ((${FOUND_BACKUPS} > ${BACKUPS_TO_KEEP})); then
#echo "Starting cleanup. Delete from line: " $((BACKUPS_TO_KEEP+1))
#cd ${DB_BACKUP_PATH} && ls -tp ${DATABASE_NAME}*${BACKUP_EXTENTION} | grep -v '/$' | tail -n +$((BACKUPS_TO_KEEP+1)) | xargs -I {} rm -- {}
#FOUND_BACKUPS=`cd ${DB_BACKUP_PATH} && ls -l ${DATABASE_NAME}*${BACKUP_EXTENTION} | wc -l`
#echo "Found ${FOUND_BACKUPS} backups after cleanup"
#echo $BACKUPS_TO_KEEP
#fi 


### End of script ####
