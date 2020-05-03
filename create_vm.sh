echo "<===================================creating vm====================================>"

ansible-playbook ./ansible_playbooks/creating_vm.yml

echo "<==========================wait for 10 minutes atleast or============================>"
echo "<=====================wait until all vm state go to shutdown============================>"
