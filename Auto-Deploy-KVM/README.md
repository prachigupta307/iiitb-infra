# Auto installation of virtual machines

Mainly we have two scripts

1. configure_network.sh
2. install_vm.sh

## Note: Run both scripts with sudo privileges

## Pre-requisites to run configure_network.sh

1. Install git.
2. Pull iiitb-infra repository from github.com/mosip-iiitb.
3. Connect to the internet with ethernet cable(don't use WiFi).


## configure_network.sh does the following things

1. Updates all the packages
2. Installs Apache Web server
3. Allows the HTTP/HTTPS traffic for Apache web server
4. Installs KVM
5. Configures bridge
6. Enables ipv4 forwarding
7. Restarts the system(if user needs)

## Pre-requisites to run install_run.sh

1. Create the folder called 'osmedia' and put the OS image in /osmedia folder

## How to run install_vm.sh

```
sh install_vm.sh <NumberOfVMS> <PrefixNameForVM> <VM-Hardware-config-file-path>

```
