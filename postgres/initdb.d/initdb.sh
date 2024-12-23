#!/usr/bin/env bash
createdb his -p $PGPORT
#psql -d his -c 'DROP SCHEMA public CASCADE;'
createdb policia -p $PGPORT
#psql -d policia -c 'DROP SCHEMA public CASCADE;'
pg_restore -d his db-backup/cleanhis.backup
pg_restore -d policia db-backup/policia.backup
