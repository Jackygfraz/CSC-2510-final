#!/bin/bash

if command -v ansible &> /dev/null; then
    echo "Ansible is already installed."
else
    # Install Ansible
    echo "Ansible is not installed. Installing..."
    sudo yum install epel-release
    sudo yum install ansible
    echo "Ansible has been installed."
fi
