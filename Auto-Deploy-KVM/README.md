# Auto installation of virtual machines

Mainly we have two scripts

1. configure_network.sh
2. install_run.sh

Run both scripts with sudo

## configure_network.sh does following things

1. Updates all the packages
2. Installs Apache Web server
3. Allows the HTTP/HTTPS traffic for Apache web server
4. Puts Kickstart file in web server
5. Installs KVM
6. Configures bridge
7. Restarts the system

## Pre-requisites to run install_run.sh

1. Create the folder called 'osmedia' and put the OS image in /osmedia folder

