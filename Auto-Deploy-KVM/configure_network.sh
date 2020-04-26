#!bin/bash

#TODO

#Clone iiitb-infra
#install git

if [ $(uname -a | egrep "*Ubuntu*" | wc -l) == "1" ]
then
	installer="apt-get"
elif [ $(uname -a | egrep "*CentOs*" | wc -l) == "1" ]
	installer="yum"
else
	echo "Bridge can't be configured in this system."
	exit
fi

$installer update -y


# Installing apache web server

$installer install -y httpd

firewall-cmd --permanent --add-service=http

firewall-cmd --permanent --add-service=https

firewall-cmd --reload


mkdir /var/www/html/install/

cp ks.cfg /var/www/html/install/

systemctl start httpd


# installing KVM packages
$installer install virt-install qemu-kvm libvirt libvirt-python  libguestfs-tools virt-manager  -y

#Configuring bridge


ETH_INTERFACE_NAME=$(ip route | awk 'NR==1{print $5}')
if [ $installer="yum" ]
then

	if [ $ETH_INTERFACE_NAME == 'virbr0' ] 
	then 
		echo "Remove the BRIDGE=virbr0 line from /etc/sysconfig/network-scripts/ifcfg-"$ETH_INTERFACE_NAME
		exit
	fi

	GATEWAY=$(ip route | awk 'NR==1{print $3}')
	ETH_FILE="ifcfg-"$ETH_INTERFACE_NAME
	hostIp=$(hostname -I | awk '{print $1}')


	cat ifcfg-virbr0 > /etc/sysconfig/network-scripts/ifcfg-virbr0
	cat ifcfg-eth > /etc/sysconfig/network-scripts/$ETH_FILE

	sed -i "s/<IPADDR>/$hostIp/" /etc/sysconfig/network-scripts/ifcfg-virbr0
	sed -i "s/<GATEWAY>/$GATEWAY/" /etc/sysconfig/network-scripts/ifcfg-virbr0
	sed -i "s/<ETH_NAME>/$ETH_INTERFACE_NAME/" /etc/sysconfig/network-scripts/$ETH_FILE


else
	if [ $(ls interfaces_backup | wc -l) == "0" ]
	then
		cp /etc/network/interfaces /etc/network/interfaces_backup
	fi
	cp interfaces /etc/network/interfaces
	sed -i "s/<ETH_NAME>/$ETH_INTERFACE_NAME/" /etc/network/interfaces
	cp interfaces /etc/network/interfaces

fi

systemctl restart network

echo "Changes reflects only when you restart the system."
echo "Do you want to restart your system?(y/n)"
read answer

if [ $answer == "y" -o $answer == "Y" ]
then
	shutdown -r now
fi

