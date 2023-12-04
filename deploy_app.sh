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

#**************************************SETUP*******************************
# variable list

ssh_key_file="$HOME/.ssh/id_rsa"             # Set the SSH key file path
ansible_cfg_path="/etc/ansible/ansible.cfg"  # path to the ansible.cfg file
sshd_config_path="/etc/ssh/sshd_config"      # path to the sshd_config file


# install ansible 
if command -v ansible &> /dev/null; then
    echo "Ansible is already installed."
else
    # Install Ansible
    echo "Ansible is not installed. Installing..."
    sudo yum install epel-release
    sudo yum install ansible
    echo "Ansible has been installed."
fi

# make essential changes to the ansible.cfg file 
if [ -e "$ansible_cfg_path" ]; then
    # Use sed to replace #host_key_checking = False with host_key_checking = False "
    sudo sed -i 's/^#host_key_checking = False/host_key_checking = False/' "$ansible_cfg_path"

    # Check if the sed command was successful
    if [ $? -eq 0 ]; then
        echo "#host_key_checking = False uncommented in $ansible_cfg_path"
    else
        echo "Failed to change configurations in $ansible_cfg_path"
    fi
else
    echo "ansible.cfg file not found at $sshd_config_path"
fi



# Generate SSH key with no passphrase
ssh-keygen -t rsa -b 2048 -f "$ssh_key_file" -N ""

# validate and add ssh key to server
eval "$(ssh-agent -s)"  
ssh-add

# The ssh key MUST be added to a github account
read -p "Stop here and take a moment to add this ssh key to your github account. Press enter to continue: " enterKey
# password must be changed to applebutter20
echo "Please make your password "applebutter20" for proper function"
sudo passwd

# This repository is essential to the rest of this application
gitDirectory="/home/$user/CSC-2510-final"

# Check if the directory exists
if [ -d "$gitDirectory" ]; then
    echo "The directory $gitDirectory exists."
else
    echo "Cloning git repo CSC-2510-final."
    git clone https://github.com/Jackygfraz/CSC-2510-final.git
fi
 

# Check if the file exists
if [ -e "$sshd_config_path" ]; then
    # Use sed to replace "PermitRootLogin no" with "PermitRootLogin yes"
    sudo sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' "$sshd_config_path"
    # Use sed to replace "PasswordAuthentication no" with "PasswordAuthentication yes"
    sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' "$sshd_config_path"

    # Check if the sed command was successful
    if [ $? -eq 0 ]; then
        echo "PermitRootLogin changed to yes in $sshd_config_path"
        echo "PasswordAuthentication changed to yes in $sshd_config_path"
        # Restart the SSH service to apply changes
        sudo systemctl restart sshd
    else
        echo "Failed to change configurations in $sshd_config_path"
    fi
else
    echo "sshd_config file not found at $sshd_config_path"
fi
#**************************************************************************

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
# Loop through the provided IP addresses and validate them
for ip_address in "$webIP" "$databaseIP"; do
    # Validate the entered IP address
    if is_valid_ip "$ip_address"; then
        echo "Valid IP address: $ip_address"
    else
        echo "Invalid IP address: $ip_address"
        error_quit "2"  # Exit the script if any IP address is invalid
    fi
done

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
siteData=$(cd swollenhippofinal ; git checkout $strEnvironment ; cat index.html)
#echo "$siteData"

# section is  used to deploy the web application taken from the git repo

echo "$siteData" > index.html

ansible-playbook launch_web_app.yml



# section makes a cron job to check if all of the servers applications are up to date every minute

#chmod +x check_for_updates.sh
#cronDirectory="$currentDir/check_for_updates.sh"
#echo "$cronDirectory"
#(crontab -l ; echo "* * * * * $cronDirectory") | crontab -
