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

After the Host reboot, check libvirtd started successfully.
```
# systemctl status libvirtd
```
Also need to ensure the kernel modules for KVM are loaded.
```
# modinfo kvm
```

## Network Configuration of the Host

Note - In our case default network interface is ens33, but depends accordingly it can be eth0, wlp2s0, enp5s0, wlan0 ..etc

With the installation of libvirtd and its services create a virtual bridge interface virbr0  with network 192.168.122.0/24. In your setup there might be requirements to use a different network. We will tune the virbr0 and ens33 ( so that ens33 is the base interface for virbr0).

Our default Network interface can be checked using below command( In our case its ens33)
```
$ ip route
default via 192.168.29.1 dev ens33 proto dhcp metric 100
192.168.29.0/24 dev ens33 proto kernel scope link src 192.168.29.22 metric 100
192.168.122.0/24 dev virbr0 proto kernel scope link src 192.168.122.1
```
So, as per our goal we need route our data through bridge(virbr0), So that the guest vm's  gets connected to internet.
Follow the below Steps

Update the interface configuration files as below :-

Updating the ens33(script), adding virbr0
```
# cat /etc/sysconfig/network-scripts/ifcfg-ens33
DEVICE=ens33
TYPE=Ethernet
BOOTPROTO=dhcp
ONBOOT=yes
BRIDGE=virbr0
NAME=ens33
```
Create a new file named "ifcfg-virbr0"  in "/etc/sysconfig/network-scripts/" directory and Configure
it as below.
```
# cat /etc/sysconfig/network-scripts/ifcfg-virbr0
DEVICE="virbr0"
BOOTPROTO=dhcp
IPADDR=192.168.29.192
NETMASK=255.255.255.0
GATEWAY=192.168.29.1
ONBOOT=yes
TYPE=Bridge
IPV6INIT=no
NAME=virbr0
DELAY=0
```
Note – Replace the IP Address / MAC/UUID Info with the appropriate in your setup.

Restart the network service
```
# systemctl restart network
```
A Clean System Reboot to ensure everything works after reboot
```
# init 6
```
Check the status of the network of Reboot
```
# systemctl status network.service
Loaded: loaded (/etc/rc.d/init.d/network; bad; vendor preset: disabled)
   Active: active (exited) since Thu 2020-04-09 10:48:53 IST; 58s ago
     Docs: man:systemd-sysv-generator(8)
  Process: 1137 ExecStart=/etc/rc.d/init.d/network start (code=exited, status=0/SUCCESS)
    Tasks: 0

Apr 09 10:48:53 localhost.localdomain systemd[1]: Starting LSB: Bring up/down networking...
Apr 09 10:48:53 localhost.localdomain network[1137]: Bringing up loopback interface:  [  OK  ]
Apr 09 10:48:53 localhost.localdomain network[1137]: Bringing up interface ens33:  [  OK  ]
Apr 09 10:48:53 localhost.localdomain network[1137]: Bringing up interface virbr0:  [  OK  ]
Apr 09 10:48:53 localhost.localdomain systemd[1]: Started LSB: Bring up/down networking.

```
Using the following command, we can check bridge is successful or not
```
$ ip route
default via 192.168.29.1 dev virbr0 proto static metric 425
192.168.29.0/24 dev virbr0 proto kernel scope link src 192.168.29.22 metric 425

$ ping google.com
PING google.com (172.217.166.174) 56(84) bytes of data.
64 bytes from bom07s20-in-f14.1e100.net (172.217.166.174): icmp_seq=1 ttl=52 time=52.9 ms
64 bytes from bom07s20-in-f14.1e100.net (172.217.166.174): icmp_seq=2 ttl=52 time=48.9 ms

```
The above output indicates that our process was successful and internet is working fine With our bridge as default interface.

### Enable the IPV4 Forwarding

IPv4 Forwarding should be enabled to enable the inter vm communication
```
# echo net.ipv4.ip_forward = 1 | tee /usr/lib/sysctl.d/60-libvirtd.conf
# /sbin/sysctl -p /usr/lib/sysctl.d/60-libvirtd.conf
```
### Configure Firewall
Setting up Firewall
Allowing the packets to passthrough the firewall. To prevent unnecessary errors later.
```
# firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -i bridge0 -j ACCEPT
# firewall-cmd --permanent --direct --passthrough ipv4 -I FORWARD -o bridge0 -j ACCEPT
# firewall-cmd --reload
```
## Creating the Guest_VM

We would be using the virt-install command to install the guest os on our Host.

The virt-install options can be viewed using the command
```
$ virt-install -h
```
In the below command we are trying to install CentOS as a guest vm from an ISO image
```
virt-install  --network bridge:virbr0 --name testvm1 \
 --os-variant=centos7.0 --ram=1024 --vcpus=1  \
 --disk path=/var/lib/libvirt/images/testvm1-os.qcow2,format=qcow2,bus=virtio,size=5 \
  --graphics none  --location=/osmedia/CentOS-7-x86_64-DVD-1810.iso \
  --extra-args="console=tty0 console=ttyS0,115200"  --check all=off
```
Note - Kept iso image in /osmedia folder
     - The Configurations can tweaked according to one's requirements.

Once above command is executed, Walk through the installation as you would on any other hardware, giving it a name, user, password, and installing programs etc.

Note - We can automate the installation process by using Kickstart files. For example, adding --initrd-inject=centos.ks to the above command and modifying the extra-args like below will inject a kickstart file named centos.ks
```
--initrd-inject=centos.ks \
--extra-args "ks=file:/centos.ks console=tty0 console=ttyS0,115200n8"
```

# Managing the Guest Vm

Some handy commands used for Managing the  guest virtual machines

List all the Guest_VM present in the system and to check their state(running, shutoff.. etc)
```
# virsh list --all
Id    Name                           State
----------------------------------------------------
 4     testvm2                        running
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
If the Guest_VM is corrupted or you want to remove or feel unnecessary the following commands should
be  executed is a sequence.
```
# virsh shutdown guest_vm_name  
# virsh undefine guest_vm_name
# virsh destroy guest_vm_name
```
Other commands(For Monitoring, Managing, networking of vm ..etc) can be viewed using
```
# virsh virsh -h
```
