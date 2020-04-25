#Add base image as starting point for image layers on top
FROM ubuntu:18.04

RUN apt-get update && \
 apt-get install -y git && \
 apt-get install -y sudo && \
 apt-get install -y curl && \
 apt-get install -y apt-utils 

#Clone the git repo of the application you want to install
RUN git clone "https://github.com/mosip-iiitb/mosip-infra"
RUN git clone "https://github.com/mosip-iiitb/iiitb-infra"

RUN cp iiitb-infra/all-playbooks.properties mosip-infra/deployment/sandbox/playbooks-properties

WORKDIR mosip-infra/deployment/sandbox

RUN sudo su

RUN sh install-mosip-kernel.sh
RUN sleep 5m

RUN sh install-mosip-pre-reg.sh
RUN sleep 10m


