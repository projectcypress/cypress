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

CYPRESS_SOURCE_FILE="/etc/apt/sources.list.d/cypress.list"
OLD_CYPRESS_REPO="https://dl.packager.io/srv/deb/projectcypress/cypress/cypress_v7/ubuntu"
NEW_CYPRESS_REPO="https://go.packager.io/srv/deb/projectcypress/cypress/cypress_v7/ubuntu"

if [[ -f "$CYPRESS_SOURCE_FILE" ]]; then
  printf "${GREEN}---> Updating Cypress apt source...${NC}\n"
  sed -i "s|$OLD_CYPRESS_REPO|$NEW_CYPRESS_REPO|g" "$CYPRESS_SOURCE_FILE"
else
  printf "${RED}---> Cypress apt source file not found: $CYPRESS_SOURCE_FILE${NC}\n"
fi

CQM_SOURCE_FILE="/etc/apt/sources.list.d/cqm-execution-service.list"
OLD_CQM_REPO="https://dl.packager.io/srv/deb/projecttacoma/cqm-execution-service/cypress_v7/ubuntu"
NEW_CQM_REPO="https://go.packager.io/srv/deb/projecttacoma/cqm-execution-service/cypress_v7/ubuntu"

if [[ -f "$CQM_SOURCE_FILE" ]]; then
  printf "${GREEN}---> Updating CQM Execution Service apt source...${NC}\n"
  sed -i "s|$OLD_CQM_REPO|$NEW_CQM_REPO|g" "$CQM_SOURCE_FILE"
else
  printf "${RED}---> CQM Execution Service apt source file not found: $CQM_SOURCE_FILE${NC}\n"
fi

printf "${GREEN}---> Downloading CQM Execution Service GPG key...${NC}\n"
curl -fsSL "https://go.packager.io/srv/deb/projecttacoma/cqm-execution-service/gpg-key.gpg" \
  -o /usr/share/keyrings/cqm-execution-service.gpg

printf "${GREEN}---> Downloading Cypress GPG key...${NC}\n"
curl -fsSL "https://go.packager.io/srv/deb/projectcypress/cypress/gpg-key.gpg" \
  -o /usr/share/keyrings/cypress.gpg

printf "${GREEN}---> Running apt update...${NC}\n"
apt-get update

# If cypress is installed
if [ $(dpkg-query -W -f='${Status}' cypress 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
  printf "${GREEN}---> Attempting to upgrade Cypress...${NC}\n"
  apt-get -y --allow-change-held-packages install cypress cqm-execution-service
  cypress run rake db:migrate
  cypress config:set RAILS_ENV=production
  systemctl restart cypress cqm-execution-service
  cypress run rake tmp:cache:clear
  cypress run rake db:migrate
  systemctl restart cypress cqm-execution-service
  cypress run rake tmp:cache:clear
else
  printf "${RED}---> Cypress not found, continuing...${NC}\n"
fi

# Ensure regenerate-secrets.service exists, then enable and run it
SERVICE_FILE="/etc/systemd/system/regenerate-secrets.service"
if [[ ! -f "$SERVICE_FILE" ]]; then
    printf "${GREEN}---> Creating regenerate-secrets.service...${NC}\n"
    cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=Regenerate cypress secret keys
Before=cypress.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c "/usr/bin/cypress config:set SECRET_KEY_BASE=$(/usr/bin/cypress run rails secret)"
ExecStartPost=/bin/systemctl disable regenerate-secrets.service

[Install]
WantedBy=multi-user.target
EOF

  printf "${GREEN}---> Enabling and running regenerate-secrets.service...${NC}\n"
  systemctl daemon-reload
  systemctl enable --now regenerate-secrets.service
  systemctl start regenerate-secrets
fi

#if description import flag true
if [ "$desc" ]
then
  cypress run rake cypress:import:descriptions
fi
echo "Done!"
