#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

CYPRESS_VERSION='v3.1.0.1'
CVU_VERSION='v3.1.0'

if [[ ! -z "$1" ]]; then
    CYPRESS_VERSION="$1"
fi

if [[ ! -z "$2" ]]; then
    CVU_VERSION="$2"
fi

# Function takes 1 parameter which is the name of the tag to pull, in $1
function pull_git_tag() {
  # If the users config has legacy config options in it then back it up and preserve file permissions
  if grep -q default_bundle "config/cypress.yml"; then
    cp --preserve config/cypress.yml config/cypress.yml.old
  fi
  # Try to run the commands as the cypress user, if we get a nonzero return value then try again
  # as root.
  sudo -u cypress git -c user.name=tmp -c user.email=tmp@tmp.com stash
  rc=$?
  if [[ $rc == 0 ]]; then
    echo "We have permission to pull cypress as the user cypress, using cypress to run git commands."
    sudo -u cypress git fetch --all
    sudo -u cypress git checkout "$1"
    # pull in case we're on a branch
    sudo -u cypress git pull
    sudo -u cypress git stash pop
    sudo -u cypress git reset HEAD
    sudo -u cypress git checkout config/cypress.yml
  else
    echo "Handling previous error..."
    echo "We do NOT have permission to pull cypress as the user cypress, using root to run git commands."
    git -c user.name=tmp -c user.name=tmp -c user.email=tmp@tmp.com stash
    git fetch --all
    git checkout "$VERSION"
    # pull in case we're on a branch
    git pull
    git stash pop
    git reset HEAD
    git checkout config/cypress.yml
  fi
}

function check_and_upgrade_ruby() {
  desired_ruby_version=$(cat .ruby-version)
  ruby_version=$(ruby -v)
  rc=$?
  if [[ $rc != 0 ]] || [[ ! $ruby_version =~ $desired_ruby_version ]]; then
    if [[ -d '/opt/ruby_build/install/master/bin' ]]; then
      # Update ruby build
      git -C "/opt/ruby_build/install/master" pull origin master
      # Move the existing build to a new location
      mv "/opt/ruby_build/builds${PWD}" "/opt/ruby_build/builds${PWD}-old"
      # Download the new ruby version
      /opt/ruby_build/install/master/bin/ruby-build "$desired_ruby_version" "/opt/ruby_build/builds${PWD}"
      rc=$?
      if [[ $rc == 0 ]]; then
        echo "Successfully upgraded ruby version."
        rm -rf "/opt/ruby_build/builds${PWD}-old"
        gem install bundler
      else
        echo "Ruby upgrade failed, moving old version back into place"
        rm -rf "/opt/ruby_build/builds${PWD}"
        mv "/opt/ruby_build/builds${PWD}-old" "/opt/ruby_build/builds${PWD}"
      fi
    # If rbenv exists for the cypress user
    elif sudo -H -u cypress bash -i -c 'type rbenv &> /dev/null'; then
      sudo -i -u cypress bash -c 'git -C "$HOME/.rbenv" pull origin master'
      sudo -i -u cypress bash -c 'git -C "$HOME/.rbenv/plugins/ruby-build" pull origin master'
      sudo -H -u cypress bash -i -c 'yes | rbenv install'
      sudo -H -u cypress bash -i -c 'gem install bundler'
    else
      echo "Unable to find ruby installer, ruby version is still out of date!"
    fi
  fi
}

function cypress_cvu_shared_upgrade_commands() {
  check_and_upgrade_ruby

  export RAILS_ENV=production
  # This fixes permission issues caused by the previous upgrade script.
  sudo chown -R cypress:cypress tmp public
  # Try to run the commands as the cypress user, if we get a nonzero return value then try again
  # as root.
  echo "Running bundle install, this can take a while!"
  sudo -E -u cypress env PATH="$PATH" bundle install
  rc=$?
  if [[ $rc != 0 ]]; then
    echo "Handling previous error..."
    echo "We do NOT have permission to run bundle as the user cypress, using root to run bundle install."
    bundle install
  fi
  sudo -E -u cypress env PATH="$PATH" bundle exec rake tmp:clear
  sudo -E -u cypress env PATH="$PATH" bundle exec rake assets:clobber
  sudo -E -u cypress env PATH="$PATH" bundle exec rake assets:precompile
  # If there is a unicorn config file available and we are using unicorn then update the unicorn
  # startup script to use it.
  if [ -f config/unicorn.rb ]; then
    echo "Adding unicorn config to service config"
    sed -E -i '/(--config-file|-c)/!s/unicorn --port ([0-9]{1,5})/unicorn --port \1 --config-file config\/unicorn.rb/' "/etc/systemd/system/$(basename "$PWD").service"
  fi
}

function upgrade_cypress() {
  echo "Running Cypress Upgrade Commands"
  cypress_cvu_shared_upgrade_commands
  sudo -E -u cypress env PATH="$PATH" bundle exec rake db:migrate
  if [ -f "config/cypress.yml.old" ]; then
    # Grab the environment variables from cypress.service and pass them to the rake task
    export ENVIRONMENT=$(grep "Environment=" /etc/systemd/system/cypress.service | sed 's/Environment=//g')
    sudo -E -u cypress env PATH="$PATH" bundle exec rake cypress:import:config[config/cypress.yml.old,"$ENVIRONMENT"]
    mv config/cypress.yml.old config/cypress.yml.bak # Move the file to a new location so subsequent upgrades to not overwrite settings
  fi
}

function upgrade_cvu() {
  echo "Running Cypress Validation Utility Upgrade Commands"
  cypress_cvu_shared_upgrade_commands
}

# If we find an /opt/cypress directory with a git repo in it then assume that cypress was installed via the chef recipe
if [ -d "/opt/cypress/.git" ]; then
  export PATH=/opt/ruby_build/builds/opt/cypress/bin:$PATH
  cd /opt/cypress || exit
  export CYPRESS_FOUND=true
elif [ -d "/home/cypress/cypress/.git" ]; then
  export PATH=/home/cypress/.rbenv/bin:/home/cypress/.rbenv/shims:$PATH
  # This is not the correct secret key, however we don't actually need the correct secret key, as none of the commands in
  # cypress_cvu_shared_upgrade_commands actually require the real secret key.
  export SECRET_KEY_BASE="xxxxxxxxxxxxx"
  cd /home/cypress/cypress || exit
  export CYPRESS_FOUND=true
else
  echo "Could not find Cypress. This warning can be safely ignored unless you had Cypress installed."
  export CYPRESS_FOUND=false
fi

if [ "$CYPRESS_FOUND" = "true" ]; then
  # We have established the location of cypress above, we can now run our commands to pull the correct tag and run upgrade commands
  echo "Found Cypress directory"

  echo "Fetching Cypress - Latest"
  pull_git_tag "$CYPRESS_VERSION"
  echo "Running upgrade commands"
  upgrade_cypress

  echo "Restarting Cypress service..."
  systemctl daemon-reload
  systemctl restart cypress

  echo "Restarting Cypress Delayed Worker service..."
  systemctl restart cypress_delayed_worker
fi

if [ -d "/opt/cypress-validation-utility/.git" ]; then
  echo "Found cypress validation utility install directory."
  export PATH=/opt/ruby_build/builds/opt/cypress-validation-utility/bin:$PATH
  cd /opt/cypress-validation-utility || exit
  export CVU_FOUND=true
elif [ -d "/home/cypress/cypress-validation-utility/.git" ]; then
  echo "Found cypress validation utility install directory."
  cd /home/cypress/cypress-validation-utility || exit
  export CVU_FOUND=true
else
  echo "Could not find the Cypress Validation Utility. This warning can be safely ignored unless you had the Cypress Validation Utility installed."
  export CVU_FOUND=false
fi

if [ "$CVU_FOUND" = "true" ]; then
  # We have established the location of the cypress validation utility and should be in its directory, now we can upgrade it
  echo "Fetching Cypress Validation Utility - Latest"
  pull_git_tag "$CVU_VERSION"
  echo "Running upgrade commands..."
  upgrade_cvu

  echo "Restarting Cypress Validation Utility service..."
  systemctl daemon-reload
  systemctl restart cypress-validation-utility
fi

echo "Installing NTP service..."
apt-get -y --fix-missing install ntp

echo "Restarting NGINX service..."
systemctl restart nginx

echo "Done!"
