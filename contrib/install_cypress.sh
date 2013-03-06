#!/bin/bash

##############################################################################
# install_cypress
#
# This script automates the manual installation instructions documented at:
# https://github.com/projectcypress/cypress/wiki/Installation-Guide
#
# It is designed to be run on a basic installation of Ubuntu 12.04 LTS 64-bit
# server (http://releases.ubuntu.com/precise/) and was tested using the ISO
# Ubuntu image named ubuntu-12.04.1-server-amd64.iso.
#
# After installing Ubuntu, log in as the admin user (the user account
# specified during the install) and perform the following commands to make
# sure all currently installed packages are current:
#
#   sudo apt-get update
#   sudo apt-get upgrade
#
# If any packages were upgraded, it is recommended to reboot, then log in
# again as the admin user and you are now ready to run this script.
#
# This script performs the following tasks:
#  1) Installs server support packages
#  2) Configures system to use an HTTP proxy if necessary
#  3) Install Git
#  4) Install RVM and Ruby 1.9.3
#  5) Install MongoDB
#  6) Install libxml2 2.8 from source
#  7) Install Nokogiri
#  8) Install Cypress application
#  9) Import measure bundle
# 10) Configure startup processes
# 11) Configure Passenger / Apache
#
# Author: Tim Taylor <ttaylor@mitre.org>
# Date:   10 Dec 2012
##############################################################################

# Variables that determine the versions of components we will install
cypress_tag="v2.1.0"
install_ruby_ver="1.9.3-p286"
install_bundler_ver="1.2.3"
install_libxml_ver="2.8.0"
if [ $cypress_tag = "v2.1.0" ]; then
  install_nokogiri_ver="1.5.6"
  cypress_bundle_ver="2.1.0"
else
  install_nokogiri_ver="1.5.5"
  cypress_bundle_ver="2.0.0"
fi
install_passenger_ver="3.0.18"

###################################################
# You shouldn't need to modify anything below here.
###################################################

mongodb_key_id="7F0CEB10"
libxml_archive="libxml2-${install_libxml_ver}.tar.gz"

# Variables that are set by options to the script
config_proxy=0
proxy_host=""
proxy_port=80
import_valuesets=0
nlm_user=""
nlm_passwd=""
bundle_rev="latest"
complete_bundle_ver="${cypress_bundle_ver}-${bundle_rev}"

###################################################
# Functions used by the script
###################################################

#####
# Adjusts some variables based on the cypress version we were asked to install
#####
function adjust_for_cypress_version {
  cypress_ver=${cypress_tag:1}
  complete_bundle_ver="${cypress_ver}-${bundle_rev}"
}

#####
# Display a message in red text.
# Parameters:
#   1) the message to display (required)
#   2) extra options to pass to the echo command (optional)
#####
function fail {
  echo $2 -e "\E[31;40m\E[1m$1\E[0m"
}

#####
# Display a message in green text.
# Parameters:
#   1) the message to display (required)
#   2) extra options to pass to the echo command (optional)
#####
function success {
  echo $2 -e "\E[32;40m\E[1m$1\E[0m"
}

#####
# Display a failure message and then terminate the script.
# Parameters:
#   1) the failure message to display.
# Exit code:
#   2
#####
function abort {
  fail "$1"
  exit 2
}

#####
# Displays a success or failure message depending on the value of the status
# code.  A status of 0 indicates success.
# Parameters:
#   1) The status code to test. (required)
#   2) The message to display if the status code indicates success. (required)
#   3) The message to display if the status code indicates failure. (required)
#   4) A message to diplay before terminating the script. (optional)
#####
function success_or_fail {
  if [ $1 -eq 0 ]; then
    success "$2"
  else
    fail "$3"
    if [ $# -eq 4 ]; then
      abort "$4"
    fi
  fi
}

#####
# Checks if a package is installed, and installs it if not.
# Parameters:
#   1) The name of the package that needs to be installed. (required)
#   2) A regular expression to compare to the installed package version. If
#      the regex matches, an acceptable message is displayed, otherwise a
#      message is displayed to indicate the version may pose a problem.
#      (optional)
#####
function install_pkg {
  output=`dpkg-query -W -f='\${Status}|\${Version}' $1 2> /dev/null`
  ec=$?
  status=${output%|*}
  version=${output#*|}
  install=1
  if [ $ec -eq 0 ]; then
    if [[ $status = *\ installed ]]; then
      success "already installed ($version)" "-n"
      install=0
    fi
  fi
  if [ $install -eq 1 ]; then
    apt-get -y -qq install $1 &> /dev/null
    # get the version that was installed
    output=`dpkg-query -W -f='\${Status}|\${Version}' $1 2> /dev/null`
    version=${output#*|}
    if [ $? -eq 0 ]; then
      success "done" "-n"
    else
      fail "failed" "-n"
    fi
  fi
  # perform version test if required
  if [ $# -eq 2 ]; then
    if [[ "$version" =~ $2 ]]; then
      success " - acceptable"
    else
      fail " - incompatible"
    fi
  else
    echo
  fi
}

#####
# Checks if a Ruby Gem is installed, and installs it if not.
# Parameters:
#   1) The gem name that needs to be installed.
#   2) The version of the gem that needs to be installed.
#####
function install_gem {
  output=`gem list ${1} -i -v "${2}" --local &> /dev/null`
  if [ $? -eq 0 ]; then
    success "already installed (${2})"
  else
    gem install $1 -v "$2" $3 &> /dev/null
    success_or_fail $? "done." "failed."
  fi
}

#####
# Removes comment markings from the start of lines in a file.
# Parameters:
#   1) A regular expression that will match the comment delimiter to be
#      removed from the line. (required)
#   2) A regular expression that will match lines that need to be uncommented.
#      (required)
#   3) The file that will be processed. (required)
#####
function uncomment_line {
  sed -i -e "/$2/ s/$1//" $3
}

#####
# Prints a helpful message showing all the parameters this script accepts.
# Parameters:
#   None.
#####
function usage {
  cat << HELP_END
${0} [--help] [--proxyhost hostname] [--proxyport port]
[--nlm_user username] [--nlm_passwd password] [--import[=version]]
[--cypress=[latest|tag]]

Options:
  --cypress
    This option will specify the version of cypress to be installed.  If
    latest is specified then the most recent stable version will be installed,
    otherwise, the value provided is assumed to be the Cypress version tag
    that should be installed. The default value is ${cypress_tag}.

  --import
    This option will cause a CQM measure bundle to be imported, and code
    valuesets to be downloaded from NLM and cached locally (if needed). This
    option can accept a bundle version, which will cause a specific bundle
    version compatible with the cypress version to be imported. If no value is
    provided, the latest bundle available for the cypress version will be 
    assumed.

  --nlm_passwd
    The account password that will be used to retrieve clinical valuesets from
    the UMLS service. This is a mandatory option if --import is used.

  --nlm_user
    The account username used to retrive valuesets from the UMLS server.
    Go to https://uts.nlm.nih.gov/license.html to apply for an account.
    Account management can not be handled by the Cypress team. This is a
    mandatory option if --import is used.

  --proxyhost
    The hostname of the HTTP proxy server that should be used to access the
    internet.

  --proxyport
    The port number used by the HTTP proxy server to access the internet.
    Defaults to 80.
HELP_END
}

#===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
# The main script starts here.
#===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+

# Check OS vendor and version
os_vendor=""
os_release=""
if [ -x /usr/bin/lsb_release ]; then
  os_vendor=`/usr/bin/lsb_release -s --id`
  os_release=`/usr/bin/lsb_release -s --release`
  #echo "$os_vendor $os_release"
  if [[ $os_vendor != *Ubuntu ]]; then
    abort "This installer only supports installation on Ubuntu linux."
  fi
  if [[ $os_release != *12.04 ]]; then
    echo "This installer was only tested on Ubuntu 12.04.  Your are using ${os_release}."
    echo "Continuing anyway."
  fi
else
  echo "This script only supports Ubuntu linux and we can't determine your OS vendor."
  echo "We will continue anyway, and hope for the best."
fi

##########
# Process script arguments
##########
#echo "$# arguments were given."
if [ $# -gt 0 ]; then
  #echo "Processing args..."
  while [ $# -gt 0 ]; do
    case "$1" in
      --import)
        import_valuesets=1
        shift
        ;;

      --import*)
        import_valuesets=1
        bundle_rev=${1#--import=}
        if [ -z $bundle_rev ]; then
          bundle_rev="latest"
        fi
        shift
        ;;

      --cypress*)
        ver=${1#--cypress=}
        if [ "$ver" = "latest" ]; then
          cypress_tag="master"
        else
          cypress_tag=$ver
        fi
        shift
        ;;
        

      --proxyhost)
        if [ $# -ge 2 ]; then
          proxy_host=$2
          config_proxy=1
          shift; shift
        else
          abort "Need proxy name with --proxyhost"
        fi
        ;;

      --proxyport)
        if [ $# -ge 2 ]; then
          proxy_port=$2
          shift; shift
        else
          abort "Need proxy port with --proxyport"
        fi
        ;;

      --nlm_user)
        if [ $# -ge 2 ]; then
          nlm_user="$2"
          shift; shift
        else
          abort "Need to provide a username with --nlm_user"
        fi
        ;;

      --nlm_passwd)
        if [ $# -ge 2 ]; then
          nlm_passwd="$2"
          shift; shift
        else
          abort "Need to provide a password with --nlm_passwd"
        fi
        ;;

      --help)
        usage
        exit
        ;;

      *)
        abort "Unknown option '$1'"
        ;;
    esac
  done
fi
adjust_for_cypress_version

# Check for mandatory arguments
if [ $import_valuesets -eq 1 ]; then
  if [[ -z $nlm_user ||  -z $nlm_passwd ]]; then
    cat << NEED_UMLS_ACCOUNT_END
==============================================================================
You must have an active UMLS account in order to complete the installation of
Cypress.  The account is needed in order to download the Clinical Quality
Measure definitions and the clinical codesets.

If you have an active account, then you must provide your UMLS username and
password using the --nlm_user and --nlm_passwd options to this script
respectively.

To get a full list of options this installer supports, run:
$0 --help

To obtain a UMLS account, go to: https://uts.nlm.nih.gov/license.html
==============================================================================
NEED_UMLS_ACCOUNT_END
    exit 2
  fi
fi

# Are we being run by root?
if [ "`id -u`" != 0 ]; then
  fail "You must run this script as root to install Cypress."
  exit 1
fi

actionstr="* Use the UMLS credentials ${nlm_user}:<hidden> to retrieve valuesets"
if [ $config_proxy -eq 1 ]; then
  actionstr="${actionstr}
* Configure a system-wide HTTP proxy using ${proxy_host}:${proxy_port}"
fi
cat << WELCOME_END

==============================================================================
                  Welcome to the Cypress Installer for Ubuntu

Based on the arguments provided to the installer, the following actions will
be performed to complete the installation of Cypress on this system:

* Install SSH server for secure remote access
${actionstr}
* Install Git and any dependencies
* Install Ruby Version Manager (RVM) and Ruby interpreter
* Install MongoDB and any dependencies
* Install libxml2 (version ${install_libxml_ver}) from source
* Install Nokogiri Ruby gem (version ${install_nokogiri_ver})
* Retrieve the latest Cypress application code
* Import the latest CQM bundle
* Configure system to start Cypress jobs on system start
* Install and configure Apache web server with Passenger support
==============================================================================
WELCOME_END
echo
read -p "Do you want to continue (y/N)? " doit
if [ "$doit" == "" -o "${doit//N/n}" == "n" ]; then
  abort "Aborting per user request."
fi

##########
# Task 1: Install server support packages
##########
echo "Installing basic server support packages:"
echo -n "  Update package listings: "
apt-get update &> /dev/null
success_or_fail $? "done" "failed" "Can't continue without package lists"
echo -n "  Install expect: "
install_pkg "expect"
echo -n "  Install SSH server: "
install_pkg "openssh-server"
echo

##########
# Task 2: Configure system http proxy
##########
echo -n "Configure system proxy: "
if [ $config_proxy -eq 1 ]; then
  cat << PROFILE_END > /etc/profile.d/http_proxy.sh
# Set up system-wide HTTP proxy settings for all users
http_proxy='http://${proxy_host}:${proxy_port}/'
https_proxy='http://${proxy_host}:${proxy_port}/'
export http_proxy https_proxy
PROFILE_END

  chmod 0644 /etc/profile.d/http_proxy.sh
  source /etc/profile.d/http_proxy.sh

  cat << SUDOERS_END > /etc/sudoers.d/http_proxy
# keep http_proxy environment variables.
Defaults env_keep += "http_proxy https_proxy"
SUDOERS_END

  chmod 0440 /etc/sudoers.d/http_proxy

  success "done"
else
  echo "skipped"
fi
echo

##########
# Task 3: Install Git
##########
echo -n "Install Git: "
install_pkg "git-core"
echo

##########
# Task 4: Install RVM and Ruby 1.9.3
##########
echo "Install RVM and Ruby 1.9.3:"
# RVM dependencies
echo "   Install dependant packages:"
for p in build-essential openssl libssl-dev libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config; do
  echo -n "      $p: "
  install_pkg "$p"
done
# Install RVM itself
echo -n "   Install RVM: "
if [ -d /usr/local/rvm -a -x /usr/local/rvm/bin/rvm ]; then
  rvmver=`/usr/local/rvm/bin/rvm --version | tail -n -2 | head -n -1 | awk "{print \\\$2 \\\$3}"`
  success "already installed ($rvmver)"
else
  curl -s -L get.rvm.io | bash -l -s stable &> /dev/null
  success_or_fail $? "done" "failed"
fi
# source the RVM environment so we can use it here.
source /usr/local/rvm/scripts/rvm

# Install our ruby version
echo -n "   Install Ruby: "
rvm list | grep -q "$install_ruby_ver"
if [ $? -eq 0 ]; then
  rubyver=`ruby --version | awk "{print \\\$2}"`
  success "already installed ($rubyver)"
else
  rvm install "$install_ruby_ver" &> /dev/null
  success_or_fail $? "done" "failed"
fi

# Set our ruby as default
rvm --default "$install_ruby_ver"

# Install Bundler gem
echo -n "   Install bundler gem: "
install_gem "bundler" "$install_bundler_ver"
echo

##########
# Task 5: Install MongoDB
##########
update_sources=0
echo "Install MongoDB: "
# add repo source
echo -n "   Add 10gen apt repository: "
grep -q "deb[[:space:]]\+.*downloads-distro\.mongodb\.org" /etc/apt/sources.list
if [ $? -eq 0 ]; then
  # it's there, but could be commented out
  grep -q "^#[[:space:]]*deb[[:space:]]\+.*downloads-distro\.mongodb\.org" /etc/apt/sources.list
  if [ $? -eq 0 ]; then
    # Uncomment it
    uncomment_line "^#[[:space:]]*" "deb[[:space:]]\+.*downloads-distro\.mongodb\.org" /etc/apt/sources.list
    success "enabled"
    update_sources=1
  else
    success "already added"
  fi
else
  # need to add it
  cat << APT_MONGODB_END >> /etc/apt/sources.list

## Uncomment the following line to add software from 10gen's mongodb repository
## This software is not part of Ubuntu, but is offered by the developers of
## MongoDB.
deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen
APT_MONGODB_END
  success "added"
  update_sources=1
fi
# add 10gen signing key
echo -n "   Import 10gen package signing key: "
apt-key list | grep -q "^pub[[:space:]]\+.*/${mongodb_key_id}"
if [ $? -eq 0 ]; then
  success "already in keyring"
else
  apt-key adv --keyserver keyserver.ubuntu.com --recv "$mongodb_key_id" &> /dev/null
  success_or_fail $? "added to keyring" "failed."
fi
# update package lists
echo -n "   Update package lists: "
if [ $update_sources -eq 1 ]; then
  apt-get update > /dev/null
  success_or_fail $? "done" "failed"
else
  success "skipped - no change"
fi
# install mongodb package
echo -n "   Install mongodb-10gen: "
install_pkg "mongodb-10gen" "2\.2\.[[:digit:]]+"
# start mongodb daemon
echo -n "   Start mongodb daemon: "
output=`status mongodb`
if [[ $output = *start/running* ]]; then
  success "already running"
else
  start mongodb &> /dev/null
  success_or_fail "started" "failed" "Will need mongodb running to continue install."
fi
# Wait for mongodb to create listening socket
echo -n "   Wait for mongo network socket (may take a while): "
# Disable messages about procs blocking too long
hung_task_timeout=`cat /proc/sys/kernel/hung_task_timeout_secs`
echo 0 > /proc/sys/kernel/hung_task_timeout_secs
mongoready=0
while [ $mongoready -ne 1 ]; do
  output=`netstat --tcp -an | awk "{print \$4}"`
  if [[ $output = *:27017* ]]; then
    mongoready=1
    success "ready"
  else
    sleep 15
  fi
done
# Restore original task timeout value
echo $hung_task_timeout > /proc/sys/kernel/hung_task_timeout_secs
echo

##########
# Task 6: Install libxml2 2.8 from source
##########
echo -n "Install libxml2 verison 2.8: "
# check if it's already installed
if [ -f /usr/local/lib/libxml2.so.${install_libxml_ver} ]; then
  success "already installed"
else
  echo
  # download source tarball
  pushd /tmp > /dev/null
  echo -n "   Download libxml2 source: "
  if [ ! -e $libxml_archive ]; then
    wget -q ftp://xmlsoft.org/libxml2/$libxml_archive
    success_or_fail $? "done" "failed" "Can't continue without libxml2 $install_libxml_ver"
  else
    success "skipped - have archive"
  fi
  # unpack tarball
  echo -n "   Unpacking source archive: "
  tar xzf $libxml_archive
  success_or_fail $? "done" "failed" "Can't continue without libxml2 $install_libxml_ver"
  dirname=${libxml_archive%.tar.gz}
  chown -R root:root $dirname
  # configure sources
  echo -n "   Configure sources: "
  cd $dirname
  ./configure &> /dev/null
  success_or_fail $? "done" "failed" "Can't continue without libxml2 $install_libxml_ver"
  # compile sources
  echo -n "   Compile sources: "
  make &> /dev/null
  success_or_fail $? "done" "failed" "Can't continue without libxml2 $install_libxml_ver"
  # install software
  echo -n "   Install libxml2: "
  make install &> /dev/null
  success_or_fail $? "done" "failed" "Can't continue without libxml2 $install_libxml_ver"
  # cleanup tmp
  cd ..
  rm -rf $dirname
  rm -f $libxml_archive
  popd > /dev/null
fi
echo

##########
# Task 7: Install Nokogiri
##########
echo -n "Install nokogiri gem: "
install_gem "nokogiri" "$install_nokogiri_ver" "-- --with-xml2-dir=/usr/local/lib --with-xml2-include=/usr/local/include/libxml2"
echo

##########
# Task 8: Install Cypress application
##########
echo "Install Cypress application:"
# add cypress user
echo -n "   Create cypress user: "
id cypress &> /dev/null
if [ $? -eq 0 ]; then
  success "already exists"
  # unlock cypress users password
  passwd -u cypress &> /dev/null
else
  useradd -m -s /bin/bash -G sudo -p '$6$jbbKzIjg$mHlKBYMOX6JO9sJhEuP9ad3OBVPZFrhTEfPAFgGAExkVLCC5AmYnXUlmTik33jsPnExDvYZppo8a/vC8SMZ0V1' cypress
  success_or_fail $? "done" "failed"
fi
# add cypress user to sudo group
echo -n "   cypress user in sudo group: "
id cypress | grep -q "sudo"
if [ $? -eq 0 ]; then
  success "yes"
else
  usermod -a -G sudo cypress
  success_or_fail $? "done" "failed"
fi
# retrieve cypress application
echo -n "   Retrieve Cypress application: "
if [ -d ~cypress/cypress ]; then
  # already exists, update it
  su - -c "cd cypress; git checkout master &> /dev/null" cypress
  su - -c "cd cypress; git pull &> /dev/null" cypress
  success_or_fail $? "updated" "failed to pull updates" "Can't continue without the cypress code."
  cd ..
else
  su - -c "git clone https://github.com/projectcypress/cypress.git &> /dev/null" cypress
  success_or_fail $? "done" "failed to clone cypress repo" "Can't continue without the cypress code."
fi
echo -n "   Switching to tag ${cypress_tag}: "
su - -c "cd cypress; git checkout ${cypress_tag} &> /dev/null" cypress
success_or_fail $? "done" "failed to switch versions" "Can't continue."
# install gems needed by cypress
echo -n "   Installing Cypress gem dependencies: "
#cd ~cypress/cypress; bundle install &> /dev/null
#su - -c "cd cypress; expect -c \"set timeout 600\" -c \"spawn bundle install\" -c \"expect system:\" -c \"send CypressPwd\" -c \"expect eof\" &> /dev/null" cypress
su - -c "cd cypress; bundle install &> /dev/null" cypress
success_or_fail $? "done" "failed"
# lock cypress user's password
passwd --lock cypress &> /dev/null
echo

##########
# Task 9: Import measure bundle
##########
echo -n "Import CQM bundle:"
if [ $import_valuesets -eq 0 ]; then
  # We shouldn't import the valuesets at this time.
  echo "skipped: --import not specified"
else
  echo
  # download the measure bundle
  echo -n "   Download latest measure bundle (${complete_bundle_ver}): "
  su - -c "cd cypress; curl -s -u ${nlm_user}:${nlm_passwd} http://demo.projectcypress.org/bundles/bundle-${complete_bundle_ver}.zip -o ../bundle-${complete_bundle_ver}.zip" cypress
  success_or_fail $? "done" "failed to download bundle" "Can't continue without measure bundle."
  # import the bundle
  echo -n "   Import measure bundle: "
  su - -c "cd cypress; bundle exec rake bundle:import[../bundle-${complete_bundle_ver}.zip,true] RAILS_ENV=production &> /dev/null" cypress
  success_or_fail $? "done" "failed to import bundle" "Can't continue without importing bundle."
  # Cache valuesets
  if [ $cypress_tag = "v2.0.0" -o $cypress_tag = "V2.0.1" ]; then
    echo -n "   Downloading clinical valuesets (will take a while): "
    su - -c "cd cypress; bundle exec rake cypress:cache_valuesets[$nlm_user, $nlm_passwd] RAILS_ENV=production &> /dev/null" cypress
    success_or_fail $? "done" "failed to cache valuesets" "Can't coneinue without valuesets"
  fi
fi
echo

##########
# Task 10: Configure startup processes
##########
echo "Configure startup processes:"
# create the script that kicks off the job
echo -n "   Create delayed_job script: "
cat << DELAYED_JOB_SCRIPT_END > ~cypress/start_delayed_job.sh
#!/bin/bash
cd ~cypress/cypress
. /usr/local/rvm/scripts/rvm
bundle exec rake jobs:work RAILS_ENV=production
DELAYED_JOB_SCRIPT_END
chown cypress:cypress ~cypress/start_delayed_job.sh
chmod +x ~cypress/start_delayed_job.sh
success "done"
# create the upstart script to start job on system boot
echo -n "   Create startup script: "
cat << UPSTART_SCRIPT_END > /etc/init/delayed_worker.conf
start on started mongodb
stop on stopping mongodb

script
exec sudo -u cypress ~cypress/start_delayed_job.sh >> /tmp/delayed_worker.log 2>&1
end script
UPSTART_SCRIPT_END
chmod 0644 /etc/init/delayed_worker.conf
start delayed_worker &> /dev/null
success "done"
echo

##########
# Task 11: Configure Passenger/Apache
##########
echo "Configure Passenger and Apache:"
# install apache
echo -n "   Install apache web server: "
install_pkg apache2
# install passenger gem
echo -n "   Install passenger gem: "
install_gem passenger "$install_passenger_ver"
# install passenger dependencies
echo "   Install passenger dependencies:"
for p in libcurl4-openssl-dev apache2-prefork-dev libapr1-dev libaprutil1-dev; do
  echo -n "      $p: "
  install_pkg $p
done
# install apache passenger module
echo -n "   Install passenger module: "
passenger-install-apache2-module --auto &> /dev/null
success_or_fail $? "done" "failed"
# install Cypress site definition
echo -n "   Install Cypress website: "
cat << CYPRESS_SITE_END > /etc/apache2/sites-available/cypress
<VirtualHost *:80>
   DocumentRoot /home/cypress/cypress/public
   TimeOut 1200
   <Directory /home/cypress/cypress/public>
      AllowOverride all
      Options -MultiViews
   </Directory>
</VirtualHost>
CYPRESS_SITE_END
rm /etc/apache2/sites-enabled/000-default
ln -s ../sites-available/cypress /etc/apache2/sites-enabled/000-default
success "done"
# install passenger configuration
echo -n "   Install Passenger configuration: "
cat << PASSENGER_CONF_END > /etc/apache2/mods-available/cypress.conf
LoadModule passenger_module /usr/local/rvm/gems/ruby-${install_ruby_ver}/gems/passenger-${install_passenger_ver}/ext/apache2/mod_passenger.so
PassengerRoot /usr/local/rvm/gems/ruby-${install_ruby_ver}/gems/passenger-${install_passenger_ver}
PassengerRuby /usr/local/rvm/wrappers/ruby-${install_ruby_ver}/ruby
PASSENGER_CONF_END
ln -f -s ../mods-available/cypress.conf /etc/apache2/mods-enabled/cypress.conf
success "done"
# restart apache
echo -n "   Restart apache: "
service apache2 restart &> /dev/null
success_or_fail $? "done" "failed"
echo

echo "Done!!"
