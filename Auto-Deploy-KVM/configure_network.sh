#!bin/bash



yum update -y


# Installing apache web server

yum install -y httpd

firewall-cmd --permanent --add-service=http

firewall-cmd --permanent --add-service=https

firewall-cmd --reload


mkdir /var/www/html/install/

cp ks.cfg /var/www/html/install/

systemctl start httpd


# installing KVM packages
yum install virt-install qemu-kvm libvirt libvirt-python  libguestfs-tools virt-manager  -y


ETH_NAME=$(ip route | awk 'NR==1{print $5}')

if [ $ETH_NAME == 'virbr0' ] 
then 
	echo "Remove the BRIDGE=virbr0 line from /etc/sysconfig/network-scripts/ifcfg-"$ETH_NAME
	exit
fi

GATEWAY=$(ip route | awk 'NR==1{print $3}')
ETH_FILE="ifcfg-"$ETH_NAME

hostIp=$(hostname -I | awk '{print $1}')

cat ifcfg-virbr0 > /etc/sysconfig/network-scripts/ifcfg-virbr0
cat ifcfg-eth > /etc/sysconfig/network-scripts/$ETH_FILE

sed -i "s/<IPADDR>/$hostIp/" /etc/sysconfig/network-scripts/ifcfg-virbr0
sed -i "s/<GATEWAY>/$GATEWAY/" /etc/sysconfig/network-scripts/ifcfg-virbr0
sed -i "s/<ETH_NAME>/$ETH_NAME/" /etc/sysconfig/network-scripts/$ETH_FILE



systemctl restart network


shutdown -r

