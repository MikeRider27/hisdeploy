set -o errexit # Exit the script with error if any of the commands fail

TMP_RESOURCE=./.histemp

update() {
    container=$1
    tomcatpath=$2

    mkdir -p $TMP_RESOURCE
    echo "Use $TMP_RESOURCE to store dist (interhis only) and assets"
    #docker-compose up -d interhis

    if [[ $container == "interhis" ]]; then
        docker cp $container:/usr/local/tomcat/webapps/$tomcatpath/dist $TMP_RESOURCE/dist
    fi
    docker cp $container:/usr/local/tomcat/webapps/$tomcatpath/assets $TMP_RESOURCE/assets
    echo "Copied dist and assets from $container:/usr/local/tomcat/webapps/$tomcatpath to $TMP_RESOURCE"

    #docker-compose up -d nginx
    docker exec nginx ash -c "mkdir -p /usr/share/nginx/$tomcatpath"
    docker exec nginx ash -c "rm -rf /usr/share/nginx/$tomcatpath"
    docker exec nginx ash -c "mkdir -p /usr/share/nginx/$tomcatpath"

    if [[ $container == "interhis" ]]; then
        docker cp $TMP_RESOURCE/dist nginx:/usr/share/nginx/$tomcatpath/dist
    fi
    docker cp $TMP_RESOURCE/assets nginx:/usr/share/nginx/$tomcatpath/assets

    if [[ $container == "interhis" ]]; then
        docker exec nginx chmod -R 755 /usr/share/nginx/$tomcatpath/dist/
    fi
    docker exec nginx chmod -R 755 /usr/share/nginx/$tomcatpath/assets/
    echo "Copied dist (interhis only) and assets to nginx:/usr/share/nginx/$tomcatpath"

    docker exec nginx nginx -s reload
    echo "Nginx reloaded"

    rm -rf $TMP_RESOURCE
    echo "Cleaned temp folder $TMP_RESOURCE"
}

if [[ $# -eq 0 ]] ; then
    echo 'Please provide one of the arguments (e.g., bash updateassets.sh interhis):
    1 > outhis
    2 > interhis'
elif [ $1 == interhis ]; then
    update interhis internacion
elif [ $1 == outhis ]; then
    update outhis ambulatoria
else
    echo "Invalid Parameters, try 'bash updateassets.sh {target}', e.g., 'bash updateassets.sh interhis'"
fi
