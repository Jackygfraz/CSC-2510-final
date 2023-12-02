#!/bin/bash

# Set the SSH key file path
ssh_key_file="$HOME/.ssh/id_rsa"

# Generate SSH key with no passphrase
ssh-keygen -t rsa -b 2048 -f "$ssh_key_file" -N ""

# validate and add ssh key to server
eval "$(ssh-agent -s)"  
ssh-add


# path to the sshd_config file
sshd_config_path="/etc/ssh/sshd_config"

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
        sudo service ssh restart
    else
        echo "Failed to change configurations in $sshd_config_path"
    fi
else
    echo "sshd_config file not found at $sshd_config_path"
fi
