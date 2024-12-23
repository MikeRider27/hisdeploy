#!/bin/bash

set -o errexit # Exit the script with error if any of the commands fail

DEFAULT_GRP="hispydevelopteam"
DEFAULT_GIT_SERVER="git@gitlab.com:hispydevelopteam"

DEFAULT_WORKSPACE="/home"
DEFAULT_GIT_REPO="hisdeploy"

#DEFAULT_WORKSPACE="/opt/hispy"
#DEFAULT_GIT_REPO="hisdeploy"

declare -a ADMINS=("walker088" "tawhk" "logaiking" "tommy" "romeroru")

set -a
[ -f .his.prod.env ] && . .his.prod.env
set +a

VALIDATED=true
validateEnv() {

    if [ -z ${OUTHIS_ENV} ]; then echo "OUTHIS_ENV is unset" && VALIDATED=false; else echo "OUTHIS_ENV is set to '$OUTHIS_ENV'"; fi

    if [ -z ${DOMAIN_NAME} ]; then echo "DOMAIN_NAME is unset" && VALIDATED=false; else echo "DOMAIN_NAME is set to '$DOMAIN_NAME'"; fi
    if [ -z ${HIS_SUB_DOMAIN} ]; then echo "HIS_SUB_DOMAIN is unset" && VALIDATED=false; else echo "HIS_SUB_DOMAIN is set to '$HIS_SUB_DOMAIN'"; fi
    if [ -z ${PGE_SUB_DOMAIN} ]; then echo "PGE_SUB_DOMAIN is unset" && VALIDATED=false; else echo "PGE_SUB_DOMAIN is set to '$PGE_SUB_DOMAIN'"; fi

    if [ -z ${INT_WAR_NAME} ]; then echo "INT_WAR_NAME is unset"; else echo "INT_WAR_NAME is set to '$INT_WAR_NAME'"; fi
    if [ -z ${OUT_WAR_NAME} ]; then echo "OUT_WAR_NAME is unset" && VALIDATED=false; else echo "OUT_WAR_NAME is set to '$OUT_WAR_NAME'"; fi
    if [ -z ${HAPI_WAR_NAME} ]; then echo "HAPI_WAR_NAME is unset"; else echo "HAPI_WAR_NAME is set to '$HAPI_WAR_NAME'"; fi

    if [ -z ${CERT_NAME} ]; then echo "CERT_NAME is unset" && VALIDATED=false; else echo "CERT_NAME is set to '$CERT_NAME'"; fi
    if [ -z ${KEY_NAME} ]; then echo "HAPI_WAR_NAME is unset" && KEY_NAME=false; else echo "KEY_NAME is set to '$KEY_NAME'"; fi
    if [ -z ${HISAG_DOMAIN} ]; then echo "HISAG_DOMAIN is unset" && VALIDATED=false; else echo "HISAG_DOMAIN is set to '$HISAG_DOMAIN'"; fi
    if [ -z ${HISAG_IP} ]; then echo "HISAG_IP is unset" && VALIDATED=false; else echo "HISAG_IP is set to '$HISAG_IP'"; fi

    if [ -z ${PG_DOCKER_IMG} ]; then echo "PG_DOCKER_IMG is unset" && VALIDATED=false; else echo "PG_DOCKER_IMG is set to '$PG_DOCKER_IMG'"; fi
    if [ -z ${PG_DRIVER_CLASS} ]; then echo "PG_DRIVER_CLASS is unset" && VALIDATED=false; else echo "PG_DRIVER_CLASS is set to '$PG_DRIVER_CLASS'"; fi
    if [ -z ${PG_DRIVER} ]; then echo "PG_DRIVER is unset" && VALIDATED=false; else echo "PG_DRIVER is set to '$PG_DRIVER'"; fi
    if [ -z ${DB_HOST} ]; then echo "DB_HOST is unset" && VALIDATED=false; else echo "DB_HOST is set to '$DB_HOST'"; fi
    if [ -z ${DB_PORT} ]; then echo "DB_PORT is unset" && VALIDATED=false; else echo "DB_PORT is set to '$DB_PORT'"; fi
    if [ -z ${DB_USER} ]; then echo "DB_USER is unset" && VALIDATED=false; else echo "DB_USER is set to '$DB_USER'"; fi
    if [ -z ${DB_PW} ]; then echo "DB_PW is unset" && VALIDATED=false; else echo "DB_PW is set to *******"; fi
    if [ -z ${DB_NAME_HIS} ]; then echo "DB_NAME_HIS is unset" && VALIDATED=false; else echo "DB_NAME_HIS is set to '$DB_NAME_HIS'"; fi
    if [ -z ${DB_NAME_POLICIA} ]; then echo "DB_NAME_POLICIA is unset" && VALIDATED=false; else echo "DB_NAME_POLICIA is set to '$DB_NAME_POLICIA'"; fi

    if [ -z ${HOSP_ID} ]; then echo "HOSP_ID is unset" && VALIDATED=false; else echo "HOSP_ID is set to '$HOSP_ID'"; fi
    if [ -z "${HOSP_NAME}" ]; then echo "HOSP_NAME is unset" && VALIDATED=false; else echo "HOSP_NAME is set to '$HOSP_NAME'"; fi
    if [ -z ${HIS_ADMIN_NAME} ]; then echo "HIS_ADMIN_NAME is unset" && VALIDATED=false; else echo "HIS_ADMIN_NAME is set to '$HIS_ADMIN_NAME'"; fi
    if [ -z ${HIS_ADMIN_PASS} ]; then echo "HIS_ADMIN_PASS is unset" && VALIDATED=false; else echo "HIS_ADMIN_PASS is set to '$HIS_ADMIN_PASS'"; fi

    if [ -z ${TOMCAT_MANAGER_USER} ]; then echo "TOMCAT_MANAGER_USER is unset" && VALIDATED=false; else echo "TOMCAT_MANAGER_USER is set to '$TOMCAT_MANAGER_USER'"; fi
    if [ -z ${TOMCAT_MANAGER_PASS} ]; then echo "TOMCAT_MANAGER_PASS is unset" && VALIDATED=false; else echo "TOMCAT_MANAGER_PASS is set to *******"; fi
}

ensureGrpUsrPermission() {
    # 1. Create group
    echo "Ensure $DEFAULT_GRP being created..."
    if [ $(getent group $DEFAULT_GRP) ]; then
        echo "group $DEFAULT_GRP exists... skip groupadd"
    else
        groupadd $DEFAULT_GRP
        echo "Group $DEFAULT_GRP created"
    fi

    # 2. Create user and add users to the default group
    echo "Ensure adm being created: $adm"
    for adm in "${ADMINS[@]}"
    do
        if id "$adm" >/dev/null 2>&1; then
            echo "User $adm found... skip useradd"
        else
            echo "Creating User $adm"
            useradd -m $adm
            passwd $adm
            echo "User $adm $(id $adm) created"
        fi
        usermod -aG $DEFAULT_GRP $adm
        usermod -aG docker $adm
        echo "Ensure $adm be in the group $DEFAULT_GRP: $(id $adm)"
    done

    # 3. Ensure the workspace is created and with correct permissions
    echo "Creating $DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO"
    if [ ! -d "$DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO" ]; then
        cd $DEFAULT_WORKSPACE
        git clone $DEFAULT_GIT_SERVER/$DEFAULT_GIT_REPO.git
    else
        echo "$DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO exist... skip creation"
    fi
    cd $DEFAULT_WORKSPACE
    chmod -R 770 $DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO
    cd $DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO
    git config --global --add safe.directory $DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO
    git config core.sharedRepository group
    chgrp -R $DEFAULT_GRP .
    chmod -R g+w .
    chmod g-w .git/objects/pack/*
    find -type d -exec chmod g+s {} +
    ls -al
}

# 0. Validate .his.prod.env
validateEnv
if [ $VALIDATED == true ]; then
    echo "Passed validation: $VALIDATED"
else
    echo "Did not pass the validation..."
    exit 0
fi
#exit 0

# 1. Create users, group, and workspace
ensureGrpUsrPermission
echo "Users created, group created, workspace permission configured"
#exit 0

# 2. Update docker containers
cd $DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO
#git fetch
#git checkout 0.1.1

echo "Generating configs..."
bash shells/gen_configs.sh
unset $(grep -v '^#' .his.prod.env | sed -E 's/(.*)=.*/\1/' | xargs)

echo "Pulling, building, and recreating images..."
docker compose pull
docker compose build
docker compose up -d

for i in $(seq 1 8);
do
    echo "waiting 8 sec... $i"
    sleep 1s
done

INTERHIS_APP_VOLUME=/var/lib/docker/volumes/hisdeploy_interhis_apps
if [ -d "$INTERHIS_APP_VOLUME" ]; then
  chmod -R 777 $INTERHIS_APP_VOLUME
fi

OUTHIS_APP_VOLUME=/var/lib/docker/volumes/hisdeploy_outhis_apps
if [ -d "$OUTHIS_APP_VOLUME" ]; then
  chmod -R 777 $OUTHIS_APP_VOLUME
fi

POSTGRES_LOGS_VOLUME=/var/lib/docker/volumes/hisdeploy_postgres_logs
if [ -d "$POSTGRES_LOGS_VOLUME" ]; then
  chmod -R 777 $POSTGRES_LOGS_VOLUME
fi

POSTGRES_CONF=postgres/config/postgresql.conf
if [ -f "$POSTGRES_CONF" ]; then
  chmod -R 777 $POSTGRES_CONF
fi

git clean -fd
