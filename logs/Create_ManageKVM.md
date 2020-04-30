# Creating and Managing the Guest KVM's

## 1.Creating guest vm
We would be using the virt-install command to install the guest os on our Host.

The virt-install options can be viewed using the command
```
$ virt-install -h
```
In the sample command below, we are trying to install CentOS7 as a guest vm from an ISO image.
```
virt-install  --network bridge:virbr0 --name testvm1 \
 --os-variant=centos7.0 --ram=1024 --vcpus=1  \
 --disk path=/var/lib/libvirt/images/testvm1-os.qcow2,format=qcow2,bus=virtio,size=5 \
  --graphics none  --location=/osmedia/CentOS-7-x86_64-DVD-1810.iso \
  --extra-args="console=tty0 console=ttyS0,115200"  --check all=off
```
#### Note1: 
1. Kept iso image in /osmedia folder (location can be changed, accordingly disk path in above command should be updated) 
2. The Guest VM Configurations can tweaked according to one's requirements.

Once above command is executed, Walk through the installation as you would on any other hardware, giving it a name, user, password, and installing programs etc.
#### Note2: 
- We can automate the OS installation Configuration by using Kickstart files. For example, adding --initrd-inject=centos.ks to the above virt-install command and modifying the extra-args like below will inject a kickstart file named centos.ks
```
--initrd-inject=centos.ks \
--extra-args "ks=file:/centos.ks console=tty0 console=ttyS0,115200n8"
```

## 2.Managing guest vm's
Some handy commands used for Managing the guest virtual machines

List all the Guest_VM present in the system and to check their state(running, shutoff.. etc)
```
# virsh list --all
Id    Name                           State
----------------------------------------------------
 1    testvm2                        running
 -     testvm1                        shut off
```
Start a vm using it's name
```
# virsh start testvm1
Domain testvm1 started
```
In order to access a running system console and to log in, the following command can be used
```
# virsh console testvm1
Connected to domain testvm1
Escape character is ^]

CentOS Linux 7 (Core)
Kernel 3.10.0-1062.18.1.el7.x86_64 on an x86_64

localhost login:
```
Shutdown/Reboot the guest machines Using the following commands
```
# virsh shutdown guest_vm_name
# virsh reboot guest_vm_name
```
If the Guest_VM is corrupted or you want to remove the following commands should be executed is a sequence.
```
# virsh shutdown guest_vm_name  
# virsh undefine guest_vm_name
# virsh destroy guest_vm_name
```
Other commands(For Monitoring, Managing, networking of vm ..etc) can be viewed using
```
# virsh virsh -h
```
 
