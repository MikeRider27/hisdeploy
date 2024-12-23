#!/usr/bin/env bash

BACKUP_DIR=/db-backup
FILE_SUFFIX=${1}.backup
FILE=`date +"%Y%m%d"`${FILE_SUFFIX}
OUTPUT_FILE=${BACKUP_DIR}/${FILE}
AGE_DIR=/var/lib/postgresql/scripts/
pg_dump -F c -h localhost -U postgres -d his -f ${OUTPUT_FILE}
gzip ${OUTPUT_FILE}

# remove all files (type f) modified longer than 30 days ago under BACKUP_DIR
find ${BACKUP_DIR} -name "*.backup.gz" -type f -mtime +30 -delete

exit 0
