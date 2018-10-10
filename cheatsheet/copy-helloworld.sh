#!/bin/bash
if (( EUID != 0 )); then
    echo "You must be root to do this. Don't forget sudo." 1>&2
    exit 1
fi

mkdir -p /var/aspnetcore/helloworld
cd ../src/AspNetCoreExample/
dotnet publish -c Release
cp -r bin/Release/netcoreapp2.1/publish/* /var/aspnetcore/helloworld