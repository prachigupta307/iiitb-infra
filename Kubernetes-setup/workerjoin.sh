#!/bin/sh

path=$(pwd)
master="${path}/Ipaddress/master.txt"
worker="${path}/Ipaddress/worker.txt"

master1=$(head -n 1 $master)

my_command="ssh -n root@${master1} \"kubeadm token create --print-join-command > tokenfile\""
eval $my_command

my_command="scp root@${master1}:~/tokenfile ."
eval $my_command

comm=$(head -n 1 tokenfile)
while IFS= read -r line
do
	my_command="ssh -n root@${line} \"${comm}\""
	eval $my_command
done < $worker
