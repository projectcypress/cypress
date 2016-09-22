#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function pull_git_tag() {
  # Try to run the commands as the cypress user, if we get a nonzero return value then try again
  # as root.
  sudo -u cypress git -c user.name=tmp -c user.email=tmp@tmp.com stash
  rc=$?
  if [[ $rc == 0 ]]; then
    echo "We have permission to pull cypress as the user cypress, using cypress to run git commands."
    sudo -u cypress git fetch --all
    sudo -u cypress git checkout origin/master
    sudo -u cypress git stash pop
  else
    echo "We do NOT have permission to pull cypress as the user cypress, using root to run git commands."
    git -c user.name=tmp -c user.name=tmp -c user.email=tmp@tmp.com stash
    git git fetch --all
    git checkout origin/master
    git stash pop
  fi
}

function cypress_cvu_shared_upgrade_commands() {
  export RAILS_ENV=production
  # This fixes permission issues caused by the previous upgrade script.
  sudo chown -R cypress:cypress tmp public
  # Try to run the commands as the cypress user, if we get a nonzero return value then try again
  # as root.
  sudo -E -u cypress env PATH=$PATH bundle install > /dev/null
  rc=$?
  if [[ $rc != 0 ]]; then
    echo "We do NOT have permission to run bundle as the user cypress, using root to run bundle install."
    bundle install
  fi
  sudo -E -u cypress env PATH=$PATH bundle exec rake tmp:clear
  sudo -E -u cypress env PATH=$PATH bundle exec rake assets:clobber
  sudo -E -u cypress env PATH=$PATH bundle exec rake assets:precompile
}

function upgrade_cypress() {
  echo "Running Cypress Upgrade Commands"
  cypress_cvu_shared_upgrade_commands
}

function upgrade_cvu() {
  echo "Running Cypress Validation Utility Upgrade Commands"
  cypress_cvu_shared_upgrade_commands
}

# If we find an /opt/cypress directory with a git repo in it then assume that cypress was installed via the chef recipe
if [ -d "/opt/cypress/.git" ]; then
  export PATH=/opt/ruby_build/builds/opt/cypress/bin:$PATH
  cd /opt/cypress
  export CYPRESS_FOUND=true
elif [ -d "/home/cypress/cypress/.git" ]; then
  export PATH=/home/cypress/.rbenv/bin:/home/cypress/.rbenv/shims:$PATH
  eval "$(rbenv init -)"
  # This is not the correct secret key, however we don't actually need the correct secret key, as none of the commands in
  # cypress_cvu_shared_upgrade_commands actually require the real secret key.
  export SECRET_KEY_BASE="xxxxxxxxxxxxx"
  cd /home/cypress/cypress
  export CYPRESS_FOUND=true
else
  echo "Could not find Cypress. This warning can be safely ignored unless you had Cypress installed."
  export CYPRESS_FOUND=false
fi

if [ "$CYPRESS_FOUND" = "true" ]; then
  # We have established the location of cypress above, we can now run our commands to pull the correct tag and run upgrade commands
  echo "Found Cypress directory"

  echo "Fetching Cypress - Latest"
  pull_git_tag
  echo "Running upgrade commands"
  upgrade_cypress

  echo "Restarting Cypress service..."
  systemctl restart cypress

  echo "Restarting Cypress Delayed Worker service..."
  systemctl restart cypress_delayed_worker
fi

if [ -d "/opt/cypress-validation-utility/.git" ]; then
  echo "Found cypress validation utility install directory."
  export PATH=/opt/ruby_build/builds/opt/cypress-validation-utility/bin:$PATH
  cd /opt/cypress-validation-utility
  export CVU_FOUND=true
elif [ -d "/home/cypress/cypress-validation-utility/.git" ]; then
  echo "Found cypress validation utility install directory."
  cd /home/cypress/cypress-validation-utility
  export CVU_FOUND=true
else
  echo "Could not find the Cypress Validation Utility. This warning can be safely ignored unless you had the Cypress Validation Utility installed."
  export CVU_FOUND=false
fi

if [ "$CVU_FOUND" = "true" ]; then
  # We have established the location of the cypress validation utility and should be in its directory, now we can upgrade it
  echo "Fetching Cypress Validation Utility - Latest"
  pull_git_tag
  echo "Running upgrade commands..."
  upgrade_cvu

  echo "Restarting Cypress Validation Utility service..."
  systemctl restart cypress-validation-utility
fi

echo "Restarting NGINX service..."
systemctl restart nginx

echo "Done!"
