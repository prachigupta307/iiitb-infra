#!/bin/sh

pwd

path="/home/mosipiiitb/code/mosip-infra/deployment/sandbox/playbooks-properties"

echo "$path"

cp all-playbooks.properties "$path"

cd ../mosip-infra/deployment/sandbox/

: > install-mosip-sandbox.log

source_file="/home/mosipiiitb/code/iiitb-infra/mosip-installation-list.txt"

filecount=1

while IFS= read -r line
do
  echo "$line"
  count=0
  while IFS= read -r inner_line
  do
    echo "$inner_line"	  
    eval $inner_line > "${line}${count}.log" 2>"${line}${count}.err"
    count=$((count+1))
  done < $line
  err=$(grep -c failed=0 install-mosip-sandbox.log)
  echo "$err   $filecount"
  if [ $err != $filecount ]; then
	  echo "Breaking..$err"
	  break
  fi
  sleep 10m
  filecount=$((filecount+1))
done < $source_file

