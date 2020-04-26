#Add base image as starting point for image layers on top
FROM ubuntu:18.04

#installing packages and tools on top of ubuntu:18.04
RUN apt-get update && \
 apt-get install -y git && \
 apt-get install -y sudo && \
 apt-get install -y curl && \
 apt-get install -y apt-utils 

#Clone the git repo of the application you want to install
RUN git clone "https://github.com/mosip-iiitb/mosip-infra"
RUN git clone "https://github.com/mosip-iiitb/iiitb-infra"

#replace all-playbooks.properties with the one we have
RUN cp iiitb-infra/all-playbooks.properties mosip-infra/deployment/sandbox/playbooks-properties

#now all docker instructions will run inside mosip-infra/deployment/sandbox
WORKDIR mosip-infra/deployment/sandbox

RUN sudo su

#install mosip kernel 
RUN sh install-mosip-kernel.sh
#wait for 5 minutes, so that kernel services will get up
RUN sleep 5m

#install mosip-pre-reg
RUN sh install-mosip-pre-reg.sh
#wait for 10 minutes, so that pre-reg services will get up
RUN sleep 10m


