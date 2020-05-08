# iiitb-infra
IIITB deployment infrastructure
All the actions performed in root privileges

1) AnsibleKvminstall.sh execute
   a) ansible installation on host machine
   b) doing host checking to false in ansible.cfg file
   c) installing and configuring kvm
   d) click yes for restarting the system(it is must)
   
   
 2) before going to next step go to ansible_playbook/env_variables and edit prefix and no of vms you want.
 
 3)execute create_vm.sh
   n(user given input above) no of vms will get create after executing this script
   
 4) for confirmation of vms creation use command: virsh list --all
   it will list all your active vms 
   
 5) go to env_variables file and give no of masters,no of worker.
 6) execute fetch_vm_sh.sh
    it will give ip of every vm and store it in master,worker variables in kubernetes folder.
 7) ssh_inside_vms execution
    Downloads necessary packages of kubernetes
    ssh key setup
    kubernetes installation
    
     
 
 
   
