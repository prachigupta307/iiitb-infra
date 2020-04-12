

hostIp=$(hostname -I | awk '{print $1}')
systemctl start httpd

#keep the OS image in /osmedia
virt-install  	--network bridge:virbr0 \
		--name testvm1 \
		--os-variant=centos7.0 \
		--ram=1024 \
		--vcpus=1  \
 		--disk path=/var/lib/libvirt/images/testvm1-os.qcow2,format=qcow2,bus=virtio,size=5 \
  		--graphics none \
	      	--location=/osmedia/CentOS-7-x86_64-DVD-1810.iso \
  		--extra-args="console=tty0 console=ttyS0,115200"  -x ks=http://$hostIp/install/ks.cfg \
		--check all=off \
