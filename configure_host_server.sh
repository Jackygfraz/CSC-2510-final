#!/bin/bash
# script sets up the host ansible server 

# variable list

ssh_key_file="$HOME/.ssh/id_rsa"             # Set the SSH key file path
ansible_cfg_path="/etc/ansible/ansible.cfg"  # path to the ansible.cfg file
sshd_config_path="/etc/ssh/sshd_config"      # path to the sshd_config file

echo "when prompted always say type for proper installation"
# install git to server
sudo yum install git

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

# password must be changed to applebutter20
echo "Please make your password "applebutter20" for proper function"
sudo passwd



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
