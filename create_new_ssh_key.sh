#!/bin/bash

# Set the SSH key file path
ssh_key_file="$HOME/.ssh/id_rsa"

# Generate SSH key with no passphrase
ssh-keygen -t rsa -b 2048 -f "$ssh_key_file" -N ""

# Display the public key
echo "Public key:"
cat "$ssh_key_file.pub"
