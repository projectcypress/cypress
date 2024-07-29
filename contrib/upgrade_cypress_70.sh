#!/bin/bash

if [ $(id -u) != 0 ]; then
   echo "This script requires root permissions"
   sudo "$0" "$@"
   exit
fi

#import descriptions false by default
desc=''

while getopts 'm' flag; do
  case "${flag}" in
    m) desc="true";;
  esac
done

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

printf "${GREEN}---> Running apt update...${NC}\n"
apt-get update

# If cypress is installed
if [ $(dpkg-query -W -f='${Status}' cypress 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
  printf "${GREEN}---> Attempting to upgrade Cypress...${NC}\n"
  apt-get -y --allow-change-held-packages install cypress cqm-execution-service
  cypress run rake db:migrate
  systemctl restart cypress cqm-execution-service
  cypress run rake tmp:cache:clear
  cypress run rake db:migrate
  systemctl restart cypress cqm-execution-service
  cypress run rake tmp:cache:clear
else
  printf "${RED}---> Cypress not found, continuing...${NC}\n"
fi
#if description import flag true
if [ "$desc" ]
then
  cypress run rake cypress:import:descriptions
fi
echo "Done!"
