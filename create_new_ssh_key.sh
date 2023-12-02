#!/bin/bash

# Set the SSH key file path
ssh_key_file="$HOME/.ssh/id_rsa"

# Generate SSH key with no passphrase
ssh-keygen -t rsa -b 2048 -f "$ssh_key_file" -N ""

eval "$(ssh-agent -s)"  

ssh-add

sudo apt install sshpass
