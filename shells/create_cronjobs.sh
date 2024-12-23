#!/usr/bin/env bash
# Creates Cron Job which backups DB in Docker everyday at 23:00 host time
#sudo chmod 777 ./postgres/dbbk
croncmd_backup="docker exec postgres bash -c '/var/lib/postgresql/scripts/backup.sh _his'"
cronjob_backup="03 23 * * * $croncmd_backup"
# Creates Cron Job which Cleanups DB in Docker every 3 hours
croncmd_cleanidle="docker exec -u postgres postgres bash -c '/var/lib/postgresql/scripts/clean_idle.sh'"
cronjob_cleanidle="33 */3 * * * $croncmd_cleanidle"

if [[ $# -eq 0 ]] ; then
    echo 'Please provide one of the arguments (example: ./postgres_backup.sh add-cron-db-backup):
    1 > add-cron-db-backup
    2 > add-cron-db-cleanidle
    3 > remove-cron-db-backup
    4 > remove-cron-db-cleanidle'

elif [[ $1 == add-cron-db-backup ]]; then
    ( crontab -l | grep -v -F "$croncmd_backup" ; echo "$cronjob_backup" ) | crontab -
    echo "==>>> Backup task added to Local (not container) Cron"

elif [[ $1 == add-cron-db-cleanidle ]]; then
    ( crontab -l | grep -v -F "$croncmd_cleanidle" ; echo "$cronjob_cleanidle" ) | crontab -
    echo "==>>> Cleanup task added to Local (not container) Cron"

elif [[ $1 == remove-cron-db-backup ]]; then
    ( crontab -l | grep -v -F "$croncmd_backup" ) | crontab -
    echo "==>>> Backup task removed from Cron"

elif [[ $1 == remove-cron-db-cleanidle ]]; then
    ( crontab -l | grep -v -F "$croncmd_cleanidle" ) | crontab -
    echo "==>>> Cleanup task removed from Cron"

fi
