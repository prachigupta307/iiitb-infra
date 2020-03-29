# Installing KVM and Configuring	

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
libvirtd service will be active automatically, now verify the status of libvirtd service using below command

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

## Configure Network Bridge for KVM virtual Machines(Failed)

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

resulted in loss of network on my system 

I brought back network using the command

````
$ brctl show
bridge name     bridge id               STP enabled     interfaces
 br0           8000.00004c9f0bd2         no              wlps30
                                                       
$ sudo brctl delif br0 wlp3s0
$ sudo brctl delbr br0

```


