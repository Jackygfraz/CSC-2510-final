# CSC-2510-final
This is the Official documentation for  Automated Server Configuration, Deployment,
 and Maintenance for Multiple Environments by SwollenHuppo Enterprise

        prerequisites:
        1) At least three servers that are A ansible managmement server, a web server and a database server.
             The Ansible Management server must be in linux CentOS7 operating system for this project to
             function properly. The other two should be in debian or similar systems. 

        2) git must be installed to the Management server to be able to clone a repository

        3) Remote servers (i.e Web and Database) must be setup using the file configure_remote_servers.sh
           from the git repo found here https://github.com/Jackygfraz/CSC-2510-final.git 
           in order to establish ssh connection. This will prompt you for a specific new password and create an ssh key for the server. 

        4) Ensure all files are given proper permissions before use with chmod 755 or similar commands.
       
        Instructions for Remote server:
        1) The first steps on the remote servers must be manually done. Navigate to https://github.com/Jackygfraz/CSC-2510-final.git
           and find the file configure_remote_servers.sh or in the git repo copied later to the host server.
           Copy or download this file into each remote server and use chmod to give it executable permissions. 
        2) execute the file configure_remote_servers.sh and follow along with its prompts to properly set up the remote servers

        3) this configures sshd.config and adds an ssh key to the server. The user must also create a password (applebutter20) that is
           used across all your server.
       
        Instructions for host server:
        1)  use this link to github (https://github.com/Jackygfraz/CSC-2510-final.git) to clone this repository.
            To set up a basic ssh key and install the proper applications
      
        2)  This new repo contains the file deploy_app.sh which will need to be given 
                proper permissions and then can be run with 3 inputs, these inputs being
                the enviroment type being created (Dev, Test,or Prod), followed by
                the internal IP addresses for their Environments Web server and lastly their 
                Database server. Note: This scrip MUST be run with sudo or equivelent permissions.

        3) This script will start by installing all essentials applications, i.e Ansible. Following this it will
            setup the servers ssh keys and prompt the user for a specific password (applebutter20). 
            This also includes multiple configurations to 2 diffrent files (ansible.cfg and sshd_config)
            in etc directory.
    
        3)  This script will then validate the IP addresses as standard IPv4 addresses.
             After validation the script will add the hosts to the ansible hosts file. 
        4) Following this it will run the properly given ansible playbook to set up the given servers with 
            the proper applications. It will then copy a git repo at git@github.com:ttu-bburchfield/swollenhippofinal.git
            to download its web application on a branch specific to enviorment into a file named index.html

        5) The script will then call the ansible playbook launch_web_app.sh that will send the newly created 
            index.html to the directory /var/www/html/ in order to replace the existing web server there and then
            restart the apache service to ensure the change is applied. 
        6) A cron job will be created in order to automate the updating of the servers applications every minute
             



    Error Code List
        1) Code for standard fail case 
        2) Code for an invalid enviroment type being sent to deploy_app.sh
        3) Code for when a bad IP address is entered. deploy_app.sh will print which was entered incorrectly.
        4) Code for when any server is unreachable from the host.
