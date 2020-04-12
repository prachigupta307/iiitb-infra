# Installing Kvm on centos

## Pre-work Checks

Check Processor’s  Virtualization Extensions are enabled.
```
# grep -E 'svm|vmx' /proc/cpuinfo
```
Kernel is great than 2.6.20
```
# uname –a
```
Host Operating System is up to date.
```
# yum update -y
```

## Install the Packages

Installing the required Packages
```
# yum install virt-install qemu-kvm libvirt libvirt-python  libguestfs-tools virt-manager  -y
```

Enable and Start Services
```
# systemctl enable libvirtd
# systemctl start libvirtd
# systemctl status libvirtd
```

A Clean System Reboot to ensure everything works after reboot
```
# init 6
```

After the Host reboot, check libvirtd started successfully.
```
# systemctl status libvirtd
```
Also need to ensure the kernel modules for KVM are loaded.
```
# modinfo kvm
```

## Network Configuration

With the installation of libvirtd and its services create a virtual bridge interface virbr0  with network 192.168.122.0/24. In your setup there might be requirements to use a different network. We will tune the virbr0 and ens34 ( ens34 is the base interface for virbr0).

Update the interface configuration files as below

```
# cat /etc/sysconfig/network-scripts/ifcfg-ens34
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens34
UUID=124c3abb-6ebb-475a-92e3-10c3bb417211
DEVICE=ens34
ONBOOT=yes
BRIDGE=virbr0
```

```
# cat /etc/sysconfig/network-scripts/ifcfg-virbr0
TYPE=BRIDGE
DEVICE=virbr0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.29.69
NETMASK=255.255.255.0
GATEWAY=192.168.29.1
```
Note – Replace the IP Address / MAC/UUID Info with the appropriate in your setup.

### Enable the IPV4 Forwarding
```
# echo net.ipv4.ip_forward = 1 | tee /usr/lib/sysctl.d/60-libvirtd.conf
# /sbin/sysctl -p /usr/lib/sysctl.d/60-libvirtd.conf
```

### Configure Firewall
```
# firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -i bridge0 -j ACCEPT
# firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -o bridge0 -j ACCEPT
# firewall-cmd --reload
```

## Creating the Guest_VM

Note - Kept iso image in /osmedia folder

```
virt-install  --network bridge:virbr0 --name testvm1 \
 --os-variant=centos7.0 --ram=1024 --vcpus=1  \
 --disk path=/var/lib/libvirt/images/testvm1-os.qcow2,format=qcow2,bus=virtio,size=5 \
  --graphics none  --location=/osmedia/CentOS-7-x86_64-DVD-1810.iso \
  --extra-args="console=tty0 console=ttyS0,115200"  --check all=off
```

# Managing the Guest Vm

List all running VMs
```
# virsh list
```
List all running VMs irrespective of state.
```
# virsh list --all  
```  
Start/Shutdown/Reboot the VM
```
# virsh start guest_vm   
# virsh shutdown guest_vm
# virsh reboot guest_vm
```
Suspend/Resume VM.
```
# virsh suspend guest_vm  
# virsh resume guest_vm
```
Destroy VM instance
```
# virsh shutdown guest_vm   
# virsh undefine guest_vm  
# virsh destroy guest_vm
```
