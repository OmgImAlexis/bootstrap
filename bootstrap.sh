#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'         
NC='\033[0m' # No Color

red() {
    printf "${RED}$@${NC}\n"
}

green() {
    printf "${GREEN}$@${NC}\n"
}

blue() {
    printf "${BLUE}$@${NC}\n"
}

cyan() {
    printf "${CYAN}$@${NC}\n"
}

logSuccess() {
    local args="$*";
    echo $(green "[BOOTSTRAP]") "📗 $args";
}

logCommand() {
    local args="$*";
    echo $(blue "[BOOTSTRAP]") $(cyan "📗 $args");
}

logInfo() {
    local args="$*";
    echo $(blue "[BOOTSTRAP]") "📘 $args";
}

logError() {
    local args="$*";
    echo $(red "[BOOTSTRAP]") "📕 $args";
}

# Ensure this is run with sudo
if [[ $(id -u) -ne 0 ]]; then
  logError "Please try again with sudo";
  exit 1;
fi

# Run command and send stdout/stderr to /dev/null
run() {
    local args="$*";
    if [ ! -z $DEBUG ]
    then
        logCommand $args;
        eval $args;
    else
        $args > /dev/null 2>&1;
    fi
}

# Update packages
logInfo "Updating packages…";
run "apt-get update -y";
run "apt-get upgrade -y";

# Install essential packages
logInfo "Installing essential packages…";
run "apt-get install -y git apt-transport-https ca-certificates build-essential gcc g++ make net-tools";

# Install Python 3
logInfo "Installing Python 3…";
run "sudo apt install -y python3-pip";

# Install ansible
run "apt-get install -y ansible"

# Setup local host file for ansible-pull
run "echo 'localhost ansible_connection=local' > /etc/ansible/hosts"

# Run ansible bootstrap script
run "ansible-pull -U https://github.com/OmgImAlexis/bootstrap.git"

logSuccess "Done!";