# Kubernetes Multi-Master setup

This repository contains setup files to install and configure a multi-master Kubernetes cluster with kubeadm.

## Prerequisites and assumption

1) The script's assume all the nodes runs on **ubuntu operating system**.

2) **Tools: Curl, Openssh-server** has to be installed on all the nodes. Client machine's ssh-key has to be copied to all the nodes root user authorized keys.

3) **Minimum requirement :**
   * Three master node
   * one load balancer node
   * one worker node
   
4) Ip address of the nodes has to be updated in **Ipaddress folder**. Each line of the text contain a single IP address of the respective nodes.

   * Master.txt - contains the IP address of all the nodes which will act as master nodes. SSH-key of the 1st IP address(Node) in this file has to copied to all the other nodes root user authorized key. 
   
   * kubelb.txt - contains a single line, IP address of the node which will act as Load Balancer .
   
   * worker.txt - contains IP address of all the nodes which will act as worker nodes.

# Steps

1) Clone this repository.

   ```
   git clone https://github.com/mosip-iiitb/iiitb-infra.git
   ```
   
2) Move to the kubernetes directory.

   ```
   cd iiitb-infra/Kubernetes-setup
   ```
   
3) Update the IP address in **Ipaddress folder** as mentioned above. This step is very important.

4) Go to root

   ```
   sudo su
   ```
   
5) Start the setup by running the below command.

   ```
   sh setup.sh
   ```
