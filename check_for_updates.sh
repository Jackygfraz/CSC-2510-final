#!/bin/bash
# File Name: check_for_updates.sh
# Author: Jackson Frazier
# Purpose: This file is made to be called by cron to run a automated check on all
# installed applications on a server

# check dev servers
ansible-playbook installPackagesDev.yml
# check test servers
ansible-playbook installPackagesTest.yml
# check prod servers
ansible-playbook installPackagesProd.yml
