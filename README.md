# iiitb-infra
IIITB deployment infrastructure
**All the actions performed in root privileges

## Step 1: Execute ansible_&_kvm_install.sh
        After successful execution it will
       a) install ansible on host machine
       b) do host checking to false in ansible.cfg file
       c) install and configure kvm
       d) click yes for restarting the system(it is must)
   
   
Step 2: *Before going to next step go to env_variables/kvm_env_variables and edit prefix(names of vms you want to give) and            number of vms you want.
        *And also go to env_variables/kubernetes_env_variables and give no of masters, workers you want to create.
        
        
        
 step 3:       ![github pic](/git.png)
        
        
 
Step 3: create a folder under Auto-Deploy-KVM osmedia and keep centos image inside that.
 
Step 4 Execute create_vm.sh
        It will create n(user given input above) number of vms.
   
Step 5For confirmation of vms creation use command: 
        watch virsh list --all
        it will list all your active vms and please wait until all kvms status become shutoff
   
Step 6 Execute fetch_ip_of_vm.sh
        it will put ips of all masters and workers node in kubernetes_setup/Ipaddress text files.
 
Step 7 ssh_inside_vms execution
        Downloads necessary packages of kubernetes
        ssh key setup
        kubernetes installation
    
 
     
 
 
   
