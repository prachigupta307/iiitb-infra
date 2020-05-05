# Kubernetes Multi-Master setup

This repository contains setup files to install and configure a multi-master Kubernetes cluster with kubeadm.

## Prerequisites and assumption

1) The script's assume all the nodes runs on ubuntu operating system.
2) client machine's authorized ssh-key has to be copied to all the nodes root user.
3) Minimum requirement :
        a) Three master Node
        b) one load balancer
        c) one worker node
4) Ip address of the nodes has to be updated in Ipaddress folder. Each line of the text contain a single IP address of the respective nodes.
        a) Master.txt - contains the IP address of all the master nodes. SSH-key of the 1st IP address(Node) in this file has to copied to all the other nodes root user. 
        b) kubelb.txt - contains a single line, IP address of the API Server - Load Balancer.
        c) worker.txt - contains IP address of all the worker nodes.
        
