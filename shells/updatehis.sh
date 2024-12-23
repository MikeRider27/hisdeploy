#!/usr/bin/env bash

set -o errexit # Exit the script with error if any of the commands fail

readEnv() {
    set -a
    [ -f .his.prod.env ] && . .his.prod.env
    set +a
}

cleanEnv() {
    # Clean the env variables
    unset $(grep -v '^#' .his.prod.env | sed -E 's/(.*)=.*/\1/' | xargs)
}

stopContainers() {
    echo "Start to shutdown the containers..."
    if [ -z $(docker ps -q --no-trunc | grep $(docker compose ps -q $HIS_DOCKER)) ]; then
        echo "$HIS_DOCKER it's not running, skip..."
    else
        docker compose stop $HIS_DOCKER
        echo "$HIS_DOCKER is stopped..."
    fi

    if [ -z $(docker ps -q --no-trunc | grep $(docker compose ps -q nginx)) ]; then
        echo "nginx it's not running, skip..."
    else
        docker compose stop nginx
        echo "nginx is stopped..."
    fi
}

rollBack() {
    mkdir -p $HIS_DIR
    mkdir -p ./localwarstore/$HIS_DOCKER
    docker compose stop $HIS_DOCKER nginx
    mv $HIS_DIR/$HIS_TYPE.war ./localwarstore/$HIS_DOCKER/new.war && rm -f ./localwarstore/$HIS_DOCKER/new.war

    mv ./localwarstore/$HIS_DOCKER/last.war $HIS_DIR/$HIS_TYPE.war
    docker compose start $HIS_DOCKER
    while [ ! -d "$HIS_DIR/$HIS_TYPE" ]; do
        echo "wait for tomcat unzip $HIS_DIR/$HIS_TYPE.war"
        sleep 1s
    done
    docker-compose stop $HIS_DOCKER
    chmod -R 755 $HIS_DIR/$HIS_TYPE
    rm $HIS_DIR/$HIS_TYPE.war

    docker compose start $HIS_DOCKER nginx
}

updateHIS() {
    stopContainers

    [ -f localwarstore/$HIS_DOCKER/last.war ] && rm ./localwarstore/$HIS_DOCKER/last.war
    [ -f $HIS_DIR/$HIS_TYPE.war ] && mv $HIS_DIR/$HIS_TYPE.war ./localwarstore/$HIS_DOCKER/last.war
    rm -rf $HIS_DIR/$HIS_TYPE

    # TODO: curl -fSL https://hisag.mspbs.gov.py/warstore/$HIS_TYPE/$HIS_VERSION/$HIS_TYPE.war -o $HIS_DIR/$HIS_TYPE.war
    mv ./localwarstore/$HIS_DOCKER/$HIS_TYPE.war $HIS_DIR/$HIS_TYPE.war

    docker compose up -d $HIS_DOCKER
    echo "wait for tomcat unzip $HIS_DIR/$HIS_TYPE.war"
    while [ ! -d "$HIS_DIR/$HIS_TYPE" ]; do
        sleep 1s
        echo "..."
    done
    sleep 5s

    chmod -R 755 $HIS_DIR/$HIS_TYPE
    docker-compose stop $HIS_DOCKER
    rm $HIS_DIR/$HIS_TYPE.war

    bash ./shells/migratedb.sh $HIS_DOCKER migrate
    bash ./shells/migratedb.sh $HIS_DOCKER info

    docker compose up -d $HIS_DOCKER nginx
}

# Start the main process
readEnv

HIS_DOCKER=$1
if [ $# -eq 0 ]; then
    echo 'Please provide one of the arguments (e.g., bash migratedb.sh outhis update):
    1 > outhis update {HIS_VERSION} (e.g, master_3.1.6)
    2 > outhis rollback'

elif [ $HIS_DOCKER == outhis ]; then
    HIS_TYPE="ambulatoria"
    HIS_DIR="./outpatient/webapps"
else
    echo "Invalid Parameters, try 'bash migratedb.sh {target} {flyway operation}', e.g., 'bash migratedb.sh interhis info'"
    cleanEnv
    exit 0
fi

if [[ $2 == "update" ]]; then
    #HIS_VERSION=$3
    updateHIS
fi
if [[ $2 == "rollback" ]]; then
    rollBack
fi

cleanEnv
