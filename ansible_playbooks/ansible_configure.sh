echo "<===========================uncommenting host_key_checking================>"
sed -i "/host_key_checking = False/ s/# *//"  ./ansible.cfg 

