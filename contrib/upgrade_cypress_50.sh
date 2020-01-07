#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

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

echo "Done!"
