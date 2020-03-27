# Note: Run this file with sudo

# Delete the log files
if [ -d "/var/log/containers" ] then
	rm -r /var/log/containers
if [ -d "/var/log/log" ] then
	rm -r /var/log/nginx

#reverse of what install-moisp-kernel.sh is doing

apt-get -y remove ansible
apt-add-repository --remove ppa:ansible/ansible -y
apt-get -y remove software-properties-common


rm -r ~/code

#Reboot

shutdown -r

