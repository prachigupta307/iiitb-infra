

hostIp=$(hostname -I | awk '{print $1}')
systemctl start httpd

VM_NAME="testvm1"
RAM=1024
CPUS=1
IMAGE_NAME="testvm1-os.qcow2"
SIZE="5"


#keep the OS image in /osmedia
virt-install  	--network bridge:virbr0 \
		--name $VM_NAME \
		--os-variant=centos7.0 \
		--ram=$RAM \
		--vcpus=$CPUS  \
 		--disk path=/var/lib/libvirt/images/$IMAGE_NAME,format=qcow2,bus=virtio,size=$SIZE \
  		--graphics none \
	      	--location=/osmedia/CentOS-7-x86_64-DVD-1810.iso \
  		--extra-args="console=tty0 console=ttyS0,115200"  -x ks=http://$hostIp/install/ks.cfg \
		--check all=off 
