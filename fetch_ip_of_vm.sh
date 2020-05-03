#VIRTUAL_MACHINE_NAME=$(sudo virsh list --name)
sudo rm -rf hosts1
sudo touch hosts1
echo [all] >>  hosts1

for VIRTUAL_MACHINE_NAME in $(sudo virsh list --name); do

result=$(arp -an | grep $(virsh dumpxml $VIRTUAL_MACHINE_NAME | grep '<mac' | grep -o '\([0-9a-f][0-9a-f]:\)\+[0-9a-f][0-9a-f]') | grep -o '\([0-9]\{1,3\}\.\)\+[0-9]\{1,3\}')
echo $result ansible_connection=ssh ansible_ssh_user=root ansible_ssh_pass=admin >> hosts

done

