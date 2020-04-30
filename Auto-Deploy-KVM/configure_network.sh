#!bin/bash

#PRE-REQUISITES

#Clone iiitb-infra
#install git
#internet

echo "===========================Update start==========================="
apt-get update -y

echo "===========================Update end==========================="

# Installing apache web server

echo "===========================Apache installation start==========================="
apt-get install -y apache2

echo "===========================Apache installation completed==========================="
ufw allow 'Apache'

mkdir /var/www/html/install/

cp ks.cfg /var/www/html/install/

echo "===========================Apache service start==========================="
systemctl start apache2 


# installing KVM packages
echo "===========================KVM installation start==========================="
apt install -y qemu qemu-kvm libvirt-bin  bridge-utils  virt-manager
echo "===========================KVM installation completed==========================="
#Configuring bridge

echo "===========================Configuring bridge started==========================="

ETH_INTERFACE_NAME=$(ip route | awk 'NR==1{print $5}')

	if [ $ETH_INTERFACE_NAME == 'virbr0' ] 
	then 
		echo "Bridge is already configured."
		exit
	fi
	hostIp=$(hostname -I | awk '{print $1}')


	if [ ! -e /etc/network/interfaces_backup ]
	then
		cp /etc/network/interfaces /etc/network/interfaces_backup
	fi
	cp interfaces /etc/network/interfaces
	sed -i "s/<ETH_NAME>/$ETH_INTERFACE_NAME/" /etc/network/interfaces

echo "===========================Configuring bridge completed==========================="

echo "===========================Enabling the IPV4 Forwarding==========================="

echo net.ipv4.ip_forward = 1 | tee /usr/lib/sysctl.d/60-libvirtd.conf
/sbin/sysctl -p /usr/lib/sysctl.d/60-libvirtd.conf

echo "=============================IPV4 Forwarding Completed============================"

echo "Changes reflects only when you restart the system."
echo "Do you want to restart your system?(y/n)"
read answer

if [ $answer == "y" -o $answer == "Y" ]
then
	shutdown -r now
fi
