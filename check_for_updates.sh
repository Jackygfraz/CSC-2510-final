#!/bin/bash
# File Name: check_for_updates.sh
# Author: Jackson Frazier
# input: one directory found with pwd.
# Purpose: This file is made to be called by cron to run a automated check on all
# installed applications on a server

dir=$1
# check dev servers
ansible-playbook "$dir/installPackagesDev.yml"
# check test servers
ansible-playbook "$dir/installPackagesTest.yml"
# check prod servers
ansible-playbook "$dir/installPackagesProd.yml"
