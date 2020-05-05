#!/bin/sh

path=$(pwd)
master="${path}/Ipaddress/master.txt"
worker="${path}/Ipaddress/worker.txt"
kubelb="${path}/Ipaddress/kube-lb.txt"

########################################################RUNNING IN CLIENT SYSTEM################################################################

echo "\n***************************************************"
echo "INSTALLING CFSSL"
echo "***************************************************\n"

#Downloading CFL Certificate Binary
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

#Adding Execution permission and moving the file to the bin folder

chmod +x cfssl*
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

#Installing Kubectl
echo "\n***************************************************"
echo "INSTALLING KUBECTL"
echo "***************************************************\n"

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "\n***************************************************"
echo "CREATING CA CERTIFICATE AND PRIVATE KEY's "
echo "***************************************************\n"

#Creating the certificate authority certificate and private key using ca-config file and ca-csr file.

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

#Creating the certificate for etcd

cert_command="cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname="

while IFS= read -r line
do
	cert_command="${cert_command}${line},"
done < $master

line=$(head -n 1 $kubelb)
cert_command="${cert_command}${line},"

cert_command="${cert_command}127.0.0.1,kubernetes.default -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes"

echo "$cert_command"

eval $cert_command

echo "\n************************************************************"
echo "COPYING THE CERTIFICATES AND KEYS TO MASTER and WORKER NODES"
echo "************************************************************\n"

#Copying the certificates to master node and worker node

base_scp="scp ca.pem kubernetes.pem kubernetes-key.pem root@"                       
count=1
while IFS= read -r line
do
	echo "\n***************************************************"
	echo "COPYING TO MASTER${count}"
	echo "***************************************************\n"
	my_eval="${base_scp}${line}:~"
	eval $my_eval
	count=$(( count + 1 ))
done < $master

count=1
while IFS= read -r line
do
	echo "\n***************************************************"
	echo "COPYING TO WORKER${count}"
	echo "***************************************************\n"
	my_eval="${base_scp}${line}:~"
	eval $my_eval
	count=$(( count + 1 ))
done < $worker

echo "\n***************************************************"
echo "CONFIGURING LOAD BALANCER - API SERVER"
echo "***************************************************\n"

#setting up kubernetes master node's load balancer.

line=$(head -n 1 $kubelb)


content="#!/bin/sh\napt-get update -y\napt-get upgrade -y\napt-get install haproxy -y\n"

echo "${content}" > kubelb.sh

content="\n\n\nfrontend kubernetes\nbind ${line}:6443\noption tcplog\nmode tcp\ndefault_backend kubernetes-master-nodes\n\n\n"

content="${content}backend kubernetes-master-nodes\nmode tcp\nbalance roundrobin\noption tcp-check\n"

count=0
while IFS= read -r line
do

	content="${content}server k8s-master-${count} ${line}:6443 check fall 3 rise 2\n"
	count=$(( count + 1 ))

done < $master

echo "content=\"${content}\"" >> kubelb.sh
echo "echo \"\${content}\" >> /etc/haproxy/haproxy.cfg" >> kubelb.sh
echo "systemctl restart haproxy" >> kubelb.sh

base_command="scp kubelb.sh root@"
line=$(head -n 1 $kubelb)
base_command="${base_command}${line}:~"
eval $base_command
base_command="ssh root@${line} \"sh ./kubelb.sh\""
eval $base_command

#Installing and setting up kubeadm in master and worker nodes.

base_scp="scp kubeadm.sh root@"
count=1
while IFS= read -r line
do
	echo "\n***************************************************"
	echo "INSTALLING KUBEADM,DOCKER in MASTER${count}"
	echo "***************************************************\n"

	content="#!/bin/sh\nsudo -s\napt-get update -y\ncurl -fsSL https://get.docker.com -o get-docker.sh\nsh get-docker.sh\n"
	content="${content}usermod -aG docker master${count}\ncurl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -\n"
	content="${content}echo \"deb http://apt.kubernetes.io kubernetes-xenial main\" > /etc/apt/sources.list.d/kubernetes.list\n"
	content="${content}apt-get update -y\napt-get install kubelet kubeadm kubectl -y\nswapoff -a\nsed -i '/ swap / s/^/#/' /etc/fstab\n"

	echo "${content}" > kubeadm.sh
	my_eval="${base_scp}${line}:~"
	eval $my_eval
	my_command="ssh -n root@${line} \"sh kubeadm.sh\""
	eval $my_command
	count=$(( count + 1 ))
done < $master

count=1
while IFS= read -r line
do
	echo "\n***************************************************"
	echo "INSTALLING KUBEADM,DOCKER in WORKER${count}"
	echo "***************************************************\n"
	content="#!/bin/sh\nsudo -s\napt-get update -y\ncurl -fsSL https://get.docker.com -o get-docker.sh\nsh get-docker.sh\n"
	content="${content}usermod -aG docker worker${count}\ncurl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -\n"
	content="${content}echo \"deb http://apt.kubernetes.io kubernetes-xenial main\" > /etc/apt/sources.list.d/kubernetes.list\n"
	content="${content}apt-get update -y\napt-get install kubelet kubeadm kubectl -y\nswapoff -a\nsed -i '/ swap / s/^/#/' /etc/fstab\n"
	echo "${content}" > kubeadm.sh
	my_eval="${base_scp}${line}:~"
	eval $my_eval
	my_command="ssh -n root@${line} \"sh kubeadm.sh\""
	eval $my_command
	count=$(( count + 1 ))
done < $worker

#Configuring ETCD in all master nodes

base_scp="scp etcdsetup.sh root@"
countt=1
while IFS= read -r line
do
	echo "\n***************************************************"
	echo "CONFIGURING ETCD in MASTER${countt}"
	echo "***************************************************\n"
	countt=$(( countt + 1 ))
	content="#!/bin/sh\nmkdir /etc/etcd /var/lib/etcd\nmv ~/ca.pem ~/kubernetes.pem ~/kubernetes-key.pem /etc/etcd\n"
	content="${content}wget https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz\n"
	content="${content}tar xvzf etcd-v3.3.13-linux-amd64.tar.gz\nmv etcd-v3.3.13-linux-amd64/etcd* /usr/local/bin/\n"
	echo "${content}" > etcdsetup.sh

	content="[Unit]
Description=etcd
Documentation=https://github.com/coreos


[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${line} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${line}:2380 \\
  --listen-peer-urls https://${line}:2380 \\
  --listen-client-urls https://${line}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls https://${line}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\"
	cluster="  --initial-cluster "
	last=$(<$master wc -l)
	count=1
	while IFS= read -r inner_line
	do

		if [ $count -eq $last ]
		then
			cluster="${cluster}${inner_line}=https://${inner_line}:2380 \\"
		else
			cluster="${cluster}${inner_line}=https://${inner_line}:2380,"
		fi
		count=$((count+1))
	done < $master

	content="
${content}
${cluster}
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5



[Install]
WantedBy=multi-user.target"

	echo "content=\"${content}\"" >> etcdsetup.sh
	echo "echo \"\${content}\" > /etc/systemd/system/etcd.service" >> etcdsetup.sh
	echo "systemctl daemon-reload" >> etcdsetup.sh
	echo "systemctl enable etcd" >> etcdsetup.sh
	echo "systemctl start etcd" >> etcdsetup.sh

	my_eval="${base_scp}${line}:~"
	eval $my_eval
	my_command="ssh -n root@${line} \"sh etcdsetup.sh\""
	eval $my_command
	
done < $master

#Initializing master nodes

count=1
lb=$(head -n 1 $kubelb)
while IFS= read -r line
do

	echo "\n***************************************************"
	echo "INITIALIZING MASTER${count} KUBEADM"
	echo "***************************************************\n"

	if [ $count -ne 1 ]
	then
		my_command="ssh -n root@${line} \"rm ~/pki/apiserver.*\""
		echo "${my_command}"
		eval $my_command
		my_command="ssh -n root@${line} \"mv ~/pki /etc/kubernetes/\""
		echo "${my_command}"
		eval $my_command
	fi

	content="
apiVersion: kubeadm.k8s.io/v1beta2
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: iwken1.rdri5y93c0lerdob
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${line}
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: master${count}
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - ${lb}
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controlPlaneEndpoint: ${lb}:6443
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  external:
    caFile: /etc/etcd/ca.pem
    certFile: /etc/etcd/kubernetes.pem
    endpoints:"

	while IFS= read -r inner_line
	do

		ip="    - https://${inner_line}:2379"
		content="${content}
${ip}"

	done < $master 

	content="${content}
    keyFile: /etc/etcd/kubernetes-key.pem
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.18.2
networking:
  dnsDomain: cluster.local
  podSubnet: 10.30.0.0/24
  serviceSubnet: 10.96.0.0/12
scheduler: {}"

	echo "${content}" > config.yml
	my_command="scp config.yml root@${line}:~"
	eval $my_command
	my_command="ssh -n root@${line} \"kubeadm init --config=config.yml\""
	eval $my_command
	if [ $count -eq 1 ]
	then
		countt=1
		while IFS= read -r inner_line
		do
			if [ $countt -ne 1 ]
			then
				my_command="ssh -n root@${line} \"scp -r /etc/kubernetes/pki root@${inner_line}:~\""
				echo "$my_command"
				eval $my_command
			fi
			countt=$(( countt + 1 ))
		done < $master 
	fi

	count=$(( count + 1))

done < $master 

echo "Copy the Kubeadm join command"
sleep 45

#Joining the worker nodes to master node.

#----------------------------INCOMPLETE-----------------------#

#Configuring kubectl on the client machine

echo "\n***************************************************"
echo "CONFIGURING KUBECTL to access the MASTER NODES"
echo "***************************************************\n"

master1=$(head -n 1 $master)

my_command="ssh root@${master1} \"chmod +r /etc/kubernetes/admin.conf\""
eval $my_command

my_command="scp root@${master1}:/etc/kubernetes/admin.conf ."
eval $my_command
mkdir ~/.kube
mv admin.conf ~/.kube/config
chmod 600 ~/.kube/config
my_command="ssh root@${master1} \"chmod 600 /etc/kubernetes/admin.conf\""

#Deploying overlay network

echo "\n***************************************************"
echo "DEPLOYING OVERLAY NETWORK - CALICO "
echo "***************************************************\n"

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "\n***************************************************"
echo "WAIT 60 SEC"
echo "***************************************************\n"

sleep 60

echo "\n***************************************************"
echo "INSTALLATION COMPLETE"
echo "***************************************************\n"
