The installation will require the installation of the following components
  1. Ubuntu (these instructions are for Ubuntu version 18.04 LTS)
  2. Configure Proxy Settings
  3. Installing Git
  4. MongoDB
  5. Cypress User
  6. Rbenv
  7. Cypress Source Code and Configuration
  8. Generate a secret token
  9. Configure Startup Processes
  10. Configure Unicorn and Nginx

1. Installing Ubuntu
-------------------------------------------

The ISO for ubuntu 18.04 LTS can be downloaded from the following URL:
http://releases.ubuntu.com/18.04/

These instructions were developed against the "64-bit PC (AMD64) server install image" (ubuntu-18.04.03-live-server-amd64.iso).

Installing Ubuntu is a fairly straight-forward process, but for more details on installing Ubuntu please visit the following URLs:

**Graphical install using the desktop CD:**
https://help.ubuntu.com/community/GraphicalInstall

**Installation using the Alternate CD (more configuration options):**
https://help.ubuntu.com/18.04/installation-guide/index.html

Once Ubuntu has been installed you need to update the software on the computer using Apt.  Apt is a software package management system used by Ubuntu.  Note: the last command in the group below is only necessary if any packages were actually upgraded.

    sudo apt-get update
    sudo apt-get -y upgrade
    sudo reboot

You will likely want to install an SSH server.  This will allow you to connect remotely to the machine.

    sudo apt-get install -y openssh-server

Once SSH is installed, you can determine the IP address of the machine using the command

    ifconfig

In the output of this command, look under the block starting with an e, you should find an IP address after the label **inet addr:**.

2. Configure Proxy Settings
-------------------------------------------

This step is only required if the server you are installing Cypress onto needs to go through an HTTP proxy server to reach the internet.  These steps will ensure that the appropriate proxy settings are in place for every user that logs into the system.

Use your favourite text editor to create a file in _/etc/profile.d_ named **http_proxy.sh** with the following contents.  In the sample below, replace _your.proxy.host.com_ with the fully-qualified host name of your proxy server, and _your.proxy.port_ with the port number that the proxy server uses.

    # Set up system-wide HTTP proxy settings for all users
    http_proxy='http://your.proxy.host.com:your.proxy.port/'
    https_proxy='http://your.proxy.host.com:your.proxy.port/'
    export http_proxy https_proxy

Set proper permissions on the new file, and load the settings into the current environment.  NOTE: the proxy settings will automatically be loaded when a user logs in, but we are manually loading them here, to avoid having to log out and log back in again.

    sudo chmod 0644 /etc/profile.d/http_proxy.sh
    source /etc/profile.d/http_proxy.sh

Make sure that the _sudo_ command will allow the new proxy settings to be passed to commands it launches. This is done by using your text editor to create a file in _the /etc/sudoers.d_ directory named **http_proxy** (no extension) with the following contents:

    # keep http_proxy environment variables.
    Defaults env_keep += "http_proxy https_proxy"

Set proper permissions on the new file:

    sudo chmod 0440 /etc/sudoers.d/http_proxy

3. Installing Git
-------------------------------------------

Git is a source control system.  It will be used later to download the Cypress source code.

    sudo apt-get install -y git-core


4. Installing MongoDB
-------------------------------------------

MongoDB is the database used by Cypress.  To install MongoDB run the commands:

    echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
    sudo apt-get update
    sudo apt-get install -y mongodb-org=3.4.5 mongodb-org-mongos=3.4.5 mongodb-org-server=3.4.5 mongodb-org-shell=3.4.5 mongodb-org-tools=3.4.5
    sudo apt-mark hold mongodb-org mongodb-org-mongos mongodb-org-server mongodb-org-shell mongodb-org-tools
    sudo systemctl start mongod
    sudo systemctl enable mongod

To test connection (wait at least 15 seconds to let the db start up), run the command below.  If the command exits with a error about not being able to connect, then reboot, and log back in as the admin user.  Sometimes mongodb fails to create a network socket when it is started immediately after installation.  It should automatically start when the system is rebooted.

    mongo

This should output
**_MongoDB shell version: 3.4.5**

Type 'exit' to exit the mongo shell

    exit

5. Create Cypress User
-------------------------------------------

Add the cypress user (only if you did not create the VM with a Cypress user, i.e., when using EC2)

    sudo adduser cypress
    sudo usermod -G sudo cypress
    sudo su - cypress

**All commands below this line should be run as the cypress user.**

6. Installing Rbenv
-------------------------------------------

Rbenv is a system that allows managing different versions of Ruby.  It will allow the correct version of ruby to be easily installed on the system.  Ruby is the development language used for the Cypress application.

First we will need to install some dependencies:

    sudo apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev

Next we need to install rbenv and ruby-version

    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL -l

7. Fetching and configuring Cypress Source Code
-----------------------------------------------

**Getting the Cypress code**

    git clone https://github.com/projectcypress/cypress.git
    cd cypress
    git checkout generate_cimpl_d8

**Installing the version of ruby required for your cypress version**

    rbenv install

**Installing the bundler gem in order to install the cypress dependencies**

    gem install bundler

**Installing the cypress dependencies**

    bundle install

8. Fetching the measure calculation engine
-----------------------------------------------

**Install the additional dependencies for the application**

    sudo apt-get -y install nodejs
    npm install -g yarn

**Getting the measure calculation engine code**

    cd ../
    git clone https://github.com/projectcypress/js-ecqm-engine
    cd js-ecqm-engine

**Installing measure calculation dependencies**

    yarn install

9. Running the required services
-----------------------------------------------

Complete each of the steps below in a separate Terminal window as the Cypress user (so they are all running simultaneously)

**Running the measure calculation engine**

    cd js-ecqm-engine
    ./bin/rabbit_worker.js

**Running the Cypress job worker**

    cd cypress
    bundle exec rake jobs:work

**Running Cypress**

    cd cypress
    rails server

Once you have completed the install, proceed to [initial setup](https://github.com/projectcypress/cypress/wiki/Cypress-4-Initial-Setup) and install the 2019 measure bundle.
