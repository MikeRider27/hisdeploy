#!/usr/bin/env bash

set -o errexit # Exit the script with error if any of the commands fail

# Ref: https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs
#export $(grep -v '^#' .his.prod.env | xargs)
set -a
[ -f .his.prod.env ] && . .his.prod.env
set +a

flywayBaseline() {
    schema=$1
    volume=$2
    docker run --rm --network host -v "$volume" \
    flyway/flyway:7.7.3-alpine baseline -url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME_HIS?ApplicationName=his_flyway -table=$schema -user=$DB_USER -password=$DB_PW -locations=filesystem:/flyway/sql
}

flywayMigrate() {
    schema=$1
    volume=$2
    docker run --rm --network host -v "$volume" \
    flyway/flyway:7.7.3-alpine migrate -url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME_HIS?ApplicationName=his_flyway -table=$schema -user=$DB_USER -password=$DB_PW -locations=filesystem:/flyway/sql
}

flywayInfo() {
    schema=$1
    volume=$2
    docker run --rm --network host -v "$volume" \
    flyway/flyway:7.7.3-alpine info -url=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME_HIS?ApplicationName=his_flyway -table=$schema -user=$DB_USER -password=$DB_PW -locations=filesystem:/flyway/sql
}

if [[ $# -eq 0 ]] ; then
    echo 'Please provide one of the arguments (e.g., bash migratedb.sh interhis info):
    1 > interhis baseline
    2 > interhis info
    3 > interhis migrate
    4 > outhis baseline
    5 > outhis info
    6 > outhis migrate'

elif [ $1 == interhis ]; then
    rm -rf ./interhis-migration
    docker cp interhis:/usr/local/tomcat/webapps/internacion/WEB-INF/classes/db/migration ./interhis-migration
    chmod -R 777 ./interhis-migration

    if [ ! -d "./interhis-migration" ] ; then
        echo "./interhis-migration not found"
        exit 1
    fi

    if [ $2 == info ]; then
        flywayInfo "flyway_schema_history" "$(pwd)/interhis-migration:/flyway/sql"
    elif [ $2 == baseline ]; then
        flywayBaseline "flyway_schema_history" "$(pwd)/interhis-migration:/flyway/sql"
    elif [ $2 == migrate ]; then
        flywayMigrate "flyway_schema_history" "$(pwd)/interhis-migration:/flyway/sql"
    fi

    rm -rf ./interhis-migration

elif [ $1 == outhis ]; then
    rm -rf ./outhis-migration
    docker cp outhis:/usr/local/tomcat/webapps/ambulatoria/WEB-INF/classes/sql ./outhis-migration
    chmod -R 777 ./outhis-migration

    if [ ! -d "./outhis-migration" ] ; then
        echo "./outhis-migration not found"
        exit 1
    fi

    if [ $2 == info ]; then
        flywayInfo "schema_version" "$(pwd)/outhis-migration:/flyway/sql"
    elif [ $2 == baseline ]; then
        flywayBaseline "schema_version" "$(pwd)/outhis-migration:/flyway/sql"
    elif [ $2 == migrate ]; then
        flywayMigrate "schema_version" "$(pwd)/outhis-migration:/flyway/sql"
    fi

    rm -rf ./outhis-migration

else
    echo "Invalid Parameters, try 'bash migratedb.sh {target} {flyway operation}', e.g., 'bash migratedb.sh interhis info'"
fi

# Clean the env variables
unset $(grep -v '^#' .his.prod.env | sed -E 's/(.*)=.*/\1/' | xargs)
