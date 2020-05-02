# Installing KVM on Ubuntu	

This is the log of Installing KVM and Configuring it.


## Pre-requisites
Checking whether the current machine supports hardware virtualization or not

```
$ egrep -c '(vmx|svm)' /proc/cpuinfo
8
```
If the output is greater than 0 then it means your system supports Virtualization else reboot your system, then go to BIOS settings and enable VT technology.

 
Checking whether hardware supports kvm 

```
$ sudo apt-get install cpu-checker
$ sudo kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```

It indicates that current system supports kvm

## Install KVM
Run the below apt commands to install KVM and its dependencies

```
$ sudo apt update
$ sudo apt install qemu qemu-kvm libvirt-bin  bridge-utils  virtinst
```
Once the above packages are installed successfully, then your local user  will be added to the group libvirtd automatically.

## Start & enable libvirtd service
libvirtd service will be active by default(after installing the kvm packages), now verify the status of libvirtd service using below command
```
$ service libvirtd status
Loaded: loaded (/lib/systemd/system/libvirtd.service; enabled; vendor preset: enabled)
Active: active (running) since Fri 2020-03-27 19:30:21 IST; 2h 35min ago
  Docs: man:libvirtd(8)
           https://libvirt.org
Main PID: 10019 (libvirtd)
   Tasks: 19 (limit: 32768)
  CGroup: /system.slice/libvirtd.service
           ├─10019 /usr/sbin/libvirtd
           ├─10543 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --
           └─10544 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --
```

If the service is not active then use the below commands to make it active: 
```
$ sudo service libvirtd start
$ sudo update-rc.d libvirtd enable
```

## Configure Network Bridge for KVM virtual Machines

### Attempt 1 (Failure)

check the network existing networking connection using
```
$ ifconfig
wlp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.29.144  netmask 255.255.255.0  broadcast 192.168.29.255
        inet6 fe80::9473:9e6f:82f0:8c4c  prefixlen 64  scopeid 0x20<link>
        inet6 2405:201:c802:a719:fc96:ed20:a68:7b90  prefixlen 64  scopeid 0x0<global>
        inet6 2405:201:c802:a719:7e78:c28f:9840:1c23  prefixlen 64  scopeid 0x0<global>
        ether dc:a2:66:4d:d6:d1  txqueuelen 1000  (Ethernet)
        RX packets 1211238  bytes 643473689 (643.4 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 621552  bytes 229314711 (229.3 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:ba:5a:7a:30  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp2s0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 54:48:10:ce:c2:28  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 11801  bytes 1098380 (1.0 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 11801  bytes 1098380 (1.0 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
My default networking interface(through which i am accessing internet) is wlp3s0
Tried to create a bridge(named br0) and add devices to a bridge using the following command
```
$ sudo brctl add br0
$ sudo brctl addif br0 wlp3s0
```
resulted in loss of network on our system 
we brought back network using the command.

We lose the network connection because network bridging will not work when the physical network device (e.g., eth1) used for bridging is a wireless device, as most wireless device drivers do not support bridging!

```
$ brctl show
bridge name     bridge id               STP enabled     interfaces
 br0           8000.00004c9f0bd2         no              wlps30
                                                       
$ sudo brctl delif br0 wlp3s0
$ sudo brctl delbr br0

```
### Attempt 2 (Successful)
Check the existing net Configuration
```
$ ip config
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.29.47  netmask 255.255.255.0  broadcast 192.168.29.255
        inet6 2405:201:c802:a719:913:c293:c73b:8e98  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::3b48:aade:a1a:f95b  prefixlen 64  scopeid 0x20<link>
        inet6 2405:201:c802:a719:62f:84e2:3d53:3a37  prefixlen 64  scopeid 0x0<global>
        ether 00:0c:29:e7:31:9d  txqueuelen 1000  (Ethernet)
        RX packets 32372  bytes 44107742 (44.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 9428  bytes 982048 (982.0 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 614  bytes 62634 (62.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 614  bytes 62634 (62.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:07:ec:7d  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
In my case the default interface is ens33. It can be enp2s0, wlp3s0 or eth0 on your system. 
We need to edit the /etc/network/interfaces file, in order to configure the bridge. 
The below script is an example for bridge configure via dchp.
```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# Configuring Bridge interface virbr0 
auto virbr0
iface virbr0 inet dhcp
# For static configuration delete or comment out the above line and uncomment the following:
# iface br0 inet static
#  address 192.168.1.10
#  netmask 255.255.255.0
#  gateway 192.168.1.1
#  dns-nameservers 192.168.1.5
#  dns-search example.com
   bridge_ports ens33
   bridge_stp off
   bridge_fd 0
   bridge_maxwait 0
```
##### Note:
1. The bridge_ports should be modified according to the default network inteface.
2. bridge_stp off is a setting for spanning tree. If you have a possibility for network looks, you may want to turn this on.
3. bridge_fd 0 turns off all forwarding delay. Zero is no delay.
4. bridge_maxwait 0 is how long the system will wait for the Ethernet ports to come up. Zero is no wait.

After editing, re-start the system to ensure the changes have been made.
```
$ sudo shutdown -r now
```
Check the modified interfaces usind "ip addr", later check internet connectivity using ping.
In the output of "ip addr" the devices ens33 & virbr0 should be up.
```
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master virbr0 state UP group default qlen 1000
    link/ether 00:0c:29:28:58:51 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::20c:29ff:fe28:5851/64 scope link 
       valid_lft forever preferred_lft forever
3: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:0c:29:28:58:51 brd ff:ff:ff:ff:ff:ff
    inet 192.168.29.119/24 brd 192.168.29.255 scope global virbr0
       valid_lft forever preferred_lft forever
    inet6 2405:201:c802:a712:f480:91de:a095:16f0/64 scope global temporary dynamic 
       valid_lft 2242sec preferred_lft 2242sec
    inet6 2405:201:c802:a712:20c:29ff:fe28:5851/64 scope global dynamic mngtmpaddr 
       valid_lft 2242sec preferred_lft 2242sec
    inet6 fe80::20c:29ff:fe28:5851/64 scope link 
       valid_lft forever preferred_lft forever

$ ping google.com
PING google.com(bom07s18-in-x0e.1e100.net (2404:6800:4009:80c::200e)) 56 data bytes
64 bytes from bom07s18-in-x0e.1e100.net (2404:6800:4009:80c::200e): icmp_seq=1 ttl=56 time=53.2 ms
64 bytes from bom07s18-in-x0e.1e100.net (2404:6800:4009:80c::200e): icmp_seq=2 ttl=56 time=53.5 ms
64 bytes from bom07s18-in-x0e.1e100.net (2404:6800:4009:80c::200e): icmp_seq=3 ttl=56 time=52.5 ms
^C
--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 52.526/53.107/53.533/0.465 ms
```
### Enable the IPV4 Forwarding 
IPv4 Forwarding should be enabled to enable the inter vm communication. Run the below scripts to enable them.
```
# echo net.ipv4.ip_forward = 1 | tee /usr/lib/sysctl.d/60-libvirtd.conf
# /sbin/sysctl -p /usr/lib/sysctl.d/60-libvirtd.conf
```
Now we can create and manage kvms.
For creating and Managing Kvm's refer [a relative link](Create_ManageKVM.md)

 
