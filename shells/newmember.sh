#!/bin/bash

set -o errexit # Exit the script with error if any of the commands fail

NEW_USER=$1
DEFAULT_GRP="hispydevelopteam"
DEFAULT_WORKSPACE="/opt/hispy"
DEFAULT_GIT_SERVER="git@gitlab.com:hispydevelopteam"
DEFAULT_GIT_REPO="hisdeploy"

if [[ $# -eq 0 ]] ; then
    echo "please provide the user name..."
    echo "e.g.: $ bash shells/newmember.sh aston"
    exit 1
fi

# 1. Create group
if [ $(getent group $DEFAULT_GRP) ]; then
    echo "group $DEFAULT_GRP exists... skip"
else
    groupadd hispydevelopteam
    echo "Group $DEFAULT_GRP created"
fi

# 2. Create user
if id "$NEW_USER" >/dev/null 2>&1; then
    echo "User $NEW_USER $(id $NEW_USER) found... skip"
else
    useradd -m $NEW_USER
    usermod -aG hispydevelopteam $NEW_USER
    passwd $NEW_USER
    echo "User $NEW_USER $(id $NEW_USER) created"
fi

# 3. Create the work space and grant the predfined permissions
echo "Create the work space and grant the predfined permissions..."

echo "Creating $DEFAULT_WORKSPACE"
if [ ! -d "$DEFAULT_WORKSPACE" ]; then
    mkdir -p $DEFAULT_WORKSPACE
    chmod -R 770 $DEFAULT_WORKSPACE
else
    echo "$DEFAULT_WORKSPACE exist... skip"
fi

echo "Creating $DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO"
if [ ! -d "$DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO" ]; then
    cd $DEFAULT_WORKSPACE
    git clone $DEFAULT_GIT_SERVER/$DEFAULT_GIT_REPO.git
    git config core.sharedRepository group
    chgrp -R $DEFAULT_GRP .
    chmod -R g+w .
    chmod g-w .git/objects/pack/*
    find -type d -exec chmod g+s {} +
    #chgrp -R $DEFAULT_GRP $DEFAULT_WORKSPACE
    #chgrp -R $DEFAULT_GRP .git
    #chmod -R 770 .git
else
    echo "$DEFAULT_WORKSPACE/$DEFAULT_GIT_REPO exist... skip"
fi

echo "finished!"
