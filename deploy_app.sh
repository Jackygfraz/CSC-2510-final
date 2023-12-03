#!/bin/bash

# FileName: deploy_app.sh
# Author: Jackson Frazier
# Inputs: In order the file takes four inputs that are the Type of enviorment, IP of the web server, 
#   and the IP of the database server.
# Purpose: This file automates the process of setting up a new server environment
#   by taking input of the type of server enviroment and IP addresses of servers, then calling the proper 
#   ansible playbook based on type to finish setting up each server and pull the correct branch from
#   git repo git@github.com:ttu-bburchfield/swollenhippofinal.git to provide a new
#   web service application for an apache server to host

# global variables
hostsFile="/etc/ansible/hosts"
gitRepo="git@github.com:ttu-bburchfield/swollenhippofinal.git"
directory="$(pwd)/swollenhippofinal"
# Input variables
strEnvironment=$1
webIP=$2
databaseIP=$3


# statement kept to test input when uncommented
#echo "$strEnvironment"

#************************************FUNCTION LIST************************************



# function that streamlines error handling by exiting with chosen case
error_quit() {
    code= $1
    echo "Exit with Error $1"
    exit $1
}


# Function to check if a string is a valid IP address
is_valid_ip() {
    local ip=$1
    local ip_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    if [[ $ip =~ $ip_regex ]]; then
        return 0  # Valid IP address
    else
        return 1  # Invalid IP address
    fi
}

#************************************End Of LIST************************************


# This if statement validates that the user inputed a type of server or exit with code 2
if [ "$strEnvironment" != "dev" ] && [ "$strEnvironment" != "prod" ] && [ "$strEnvironment" != "test" ]; then
    echo "Invalid environment. Please enter 'dev', 'prod', or 'test'."
    exit 2
else
        echo "Valid Environment"
fi

# this section takes user input of their list of server IPs to be appended to the 
# users hosts file and grouped. Also validates ip addresses
        
# Check if input is valid for web server
if [ $? -ne 0 ]; then
        echo "Error 3: invalid Web server IP"
        exit 3
fi

# Check if input is valid for database server
if [ $? -ne 0 ]; then
        echo "Error 3: invalid Database server IP"
        exit 3
fi


# This section is used for  appending the given servers to the hosts file# 

# web server setup
echo "# Start of new Host groups" > $hostsFile # used to reset the current hosts file
echo " [web_servers_$strEnvironment]" >> $hostsFile
echo -e " $webIP\n" >> $hostsFile
echo " [web_servers_$strEnvironment:vars]" >> $hostsFile
echo " ansible_user=root" >> $hostsFile
echo -e " ansible_password=applebutter20\n" >> $hostsFile

# database setup
echo " [database_servers_$strEnvironment]" >> $hostsFile
echo -e " $databaseIP\n" >> $hostsFile
echo " [database_servers_$strEnvironment:vars]" >> $hostsFile
echo " ansible_user=root" >> $hostsFile
echo -e " ansible_password=applebutter20\n" >> $hostsFile


# This section runs the appropriate Ansible playbook based on the environment given
case $strEnvironment in
    "dev") ansible-playbook installPackagesDev.yml  ;;
    "test") ansible-playbook installPackagesTest.yml ;;
    "prod") ansible-playbook installPackagesProd.yml  ;;
    *) error_quit "2" ;;
esac


# Statement to check if the directory exists. if not then clone it, if so then say it exists
if [ -d "$directory" ]; then
    echo "Directory already exists."
else
    git clone https://github.com/ttu-bburchfield/swollenhippofinal.git
fi


# section will be used to copy and find the branch from github repo
testVar=$(cd swollenhippofinal ; git checkout $strEnvironment ; cat index.html)
echo "$testVar"
# section will be used to deploy the web application taken from the git repo
