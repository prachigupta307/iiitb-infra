echo "<===========================ansible installing============================>"

sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get -y install ansible

echo "<===========================ansible installed============================>"

echo "<=======================uncommenting host_key_checking===================>"

sed -i "/host_key_checking = False/ s/# *//"  ./ansible.cfg 

echo "<====================uncommenting host_key_checking done=================>"

echo "<========================kvm installation & setup========================>"

ansible-playbook  ./ansible_playbooks/kvm_install_and_bridge_creation.yml

echo "<====================kvm installation & setup done========================>"

echo "<=================restart require to reflect changes======================>"

echo "You want to restart system:"  
read choice

if [ "$choice" = "y" ]; then
  sudo shutdown –r now
elif [ "$choice" = "Y" ]; then
  sudo shutdown –r now
fi


echo "<=============================Restarting====================================>"
