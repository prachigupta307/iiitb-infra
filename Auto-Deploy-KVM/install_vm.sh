

hostIp=$(hostname -I | awk '{print $1}')

cp ks.cfg /var/www/html/install/ks.cfg

systemctl reload apache2
systemctl start apache2

number_of_vms=$1
vm_prefix_name=$2
hw_cfg_file_path=$3

if [ ! $# -eq 3 ]
then
	echo "Provide all inputs needed."
	echo "Syntax: sh install_vm.sh <NumberOfVMS> <PrefixNameForVM> <VM-Hardware-config-file-path>"
	exit
fi

if [ ! -e $hw_cfg_file_path ]
then
	echo "Provide the correct path for vm hardware configuration file."$#
	exit
fi
CPUS=$( egrep "<CPUS>" $hw_cfg_file_path | awk '{ print $2 }')
RAM=$( egrep "<RAM>" $hw_cfg_file_path | awk '{ print $2 }')
SIZE=$( egrep "<SIZE>" $hw_cfg_file_path | awk '{ print $2 }')
ISO_PATH=$( egrep "<ISO_PATH>" $hw_cfg_file_path | awk '{ print $2 }')

VM_NAME=$vm_prefix_name"1"
IMAGE_NAME=$VM_NAME"-os.qcow2"

if [ ! -e $ISO_PATH ]
then
	echo "Provide the location of iso file."
	exit
fi

iterate=0
while [ $iterate -lt $number_of_vms ]
do
        iterate=`expr $iterate + 1`
	virt-install  	--network bridge:virbr0 \
			--name $vm_prefix_name$iterate \
			--os-variant=centos7.0 \
			--ram=$RAM \
			--vcpus=$CPUS  \
 			--disk path=/var/lib/libvirt/images/$vm_prefix_name$iterate,format=qcow2,bus=virtio,size=$SIZE \
  			--graphics none \
		      	--location=$ISO_PATH \
  			--extra-args="console=tty0 console=ttyS0,115200"  -x ks=http://$hostIp/install/ks.cfg \
			--noautoconsole \
			--check all=off 
done
