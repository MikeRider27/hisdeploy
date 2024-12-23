#!/usr/bin/env bash

SCRIPTS_PATH=/var/lib/postgresql/scripts

psql -d his -a -f ${SCRIPTS_PATH}/clean_idle.sql
psql -d policia -a -f ${SCRIPTS_PATH}/clean_idle.sql