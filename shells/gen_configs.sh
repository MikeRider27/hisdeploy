#!/usr/bin/env bash

# Ref: https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
#export $(grep -v '^#' .his.prod.env | xargs)
set -a
[ -f .his.prod.env ] && . .his.prod.env
set +a

#export CATALINA_OPTS="-javaagent:/usr/local/apm/elastic-apm-agent.jar -Xmx15360m -Xms2048m -XX:+UseG1GC -DpgDriverClassName=$PG_DRIVER_CLASS -DpgDriver=$PG_DRIVER -DpgHost=$DB_HOST -DpgPort=$DB_PORT -DhisDbName=$DB_NAME_HIS -DpoliciaDbName=$DB_NAME_POLICIA -DpgUser=$DB_USER -DpgPass=$DB_PW -Denv=$OUTHIS_ENV"
export CATALINA_OPTS="-Xmx15360m -Xms2048m -XX:+UseG1GC -DpgDriverClassName=$PG_DRIVER_CLASS -DpgDriver=$PG_DRIVER -DpgHost=$DB_HOST -DpgPort=$DB_PORT -DhisDbName=$DB_NAME_HIS -DpoliciaDbName=$DB_NAME_POLICIA -DpgUser=$DB_USER -DpgPass=$DB_PW -Denv=$OUTHIS_ENV"
export INTERHIS_CATALINA_OPTS="-Xmx15360m -Xms2048m -XX:+UseG1GC -DjdbcUser=$DB_USER -DjdbcPass=$DB_PW"
export CERT_PATH="/etc/nginx/ssl/$HIS_SUB_DOMAIN.$DOMAIN_NAME"

export PATH=$PATH:$PWD/bin

if ! command -v frep &> /dev/null
then
    echo "frep could not be found, try download it now..."
    if [[ $(arch) == "arm64" || $(arch) == "aarch64" ]]; then
        ARCH="arm64"
    else
        ARCH="amd64"
    fi

    BINARY_NAME="frep-1.3.13-$(uname -s | tr '[:upper:]' '[:lower:]')-$ARCH"
    DIST_PATH="/usr/local/bin/frep"

    curl -fSL "https://github.com/subchen/frep/releases/download/v1.3.13/$BINARY_NAME" -o "$DIST_PATH"
    chmod +x "$DIST_PATH"
fi

# if not set 
if [[ -z "$DOCKER_UID" || -z "$DOCKER_GID" ]]; then
    export DOCKER_UID=$(id -u)
    export DOCKER_GID=$(id -g)
fi

# Generate configs using env vars with default group
DEFAULT_GRP="hispydevelopteam"

templates=(
    "inpatient/tomcat-users.xml" 
    "outpatient/tomcat-users.xml" 
    "nginx/conf.d/his.conf" 
    #nginx/conf.d/pgexporter.conf 
    "postgres/bin/clean_idle.sql" 
    "postgres/bin/create_first_ambulatoria_user.sql" 
    "postgres/bin/create_first_internacion_user.sql"
    "docker-compose.yml"
)

for f in ${templates[@]}; do
    [ -e f ] || rm $f
    frep --overwrite $f.tmpl
    chmod 770 $f
    chgrp $DEFAULT_GRP $f
done

# Clean the env variables
unset $(grep -v '^#' .his.prod.env | sed -E 's/(.*)=.*/\1/' | xargs)
