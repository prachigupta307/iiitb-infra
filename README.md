# iiitb-infra
IIITB deployment infrastructure
All the actions performed in root privileges

1) AnsibleKvminstall.sh execute
   a) ansible installation on host machine
   b) doing host checking to false in ansible.cfg file
   c) installing and configuring kvm
   d) click yes for restarting the system(it is must)
   
   
 2) before going to next step go to env_variables/kvm_env_variables and edit prefix and no of vms you want.
  again go to env_variables/kubernetes_env_variables and give no of masters, workers you want to create.
   
 
 3)execute create_vm.sh
   n(user given input above) no of vms will get create after executing this script
   
 4) for confirmation of vms creation use command:watch virsh list --all
   it will list all your active vms and wait until all kvms status become shutoff
   
5) execute fetch_ip_of_vm.sh
         it will put ips of all masters and workers node in kubernetes_setup/Ipaddress text files.
 
 6) ssh_inside_vms execution
    Downloads necessary packages of kubernetes
    ssh key setup
    kubernetes installation
    
 7)  
     
 
 
   
