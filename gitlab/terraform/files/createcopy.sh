#!/bin/bash
if [ -f ./files/temp/ip-instance ]; then

    if [ -f ./files/temp/docker-compose.yml ];then
        rm ./files/temp/docker-compose.yml
    fi

    cat ./files/docker-compose.yml | sed s/YOUR-VM-IP/$(cat ./files/temp/ip-instance)/ > ./files/temp/docker-compose.yml
else
    echo "ip-instance not exist"
    exit 1
fi