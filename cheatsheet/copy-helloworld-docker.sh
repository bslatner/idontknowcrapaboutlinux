#!/bin/bash
if (( EUID != 0 )); then
    echo "You must be root to do this. Don't forget sudo." 1>&2
    exit 1
fi

mkdir -p /var/aspnetcore/helloworld-docker
cd ..
docker-compose build
cp docker*.yml /var/aspnetcore/helloworld-docker
