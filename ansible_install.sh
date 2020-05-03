echo "<===========================ansible installing============================>"

sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get -y install ansible

echo "<===========================ansible installed============================>"

echo "<=======================uncommenting host_key_checking===================>"

sed -i "/host_key_checking = False/ s/# *//"  ./ansible.cfg 

echo "<====================uncommenting host_key_checking done=================>"
