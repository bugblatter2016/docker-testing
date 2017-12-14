# How to build this image
# > docker build -t r10k_test --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa_github_readonly_deploy_key)" .
#
# Create new container based on the image and run in detached mode
# > docker run --name r10k_test_1 -d -t -i r10k_test /bin/bash
#
# Connect to the new container
# docker exec -ti r10k_test_1 /bin/bash


# Use basic ubuntu image / pull latest
FROM ubuntu:latest

# update apt repos then install some basic pre-reqs
RUN apt-get update && apt-get install -y wget

# add puppet 5 repo
RUN wget http://apt.puppetlabs.com/puppet5-release-xenial.deb
RUN dpkg -i puppet5-release-xenial.deb

# now add main packages
RUN apt-get update && apt-get install -y \
  git \
  puppet-agent \
  r10k \
  lsb-release

# add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
#COPY id_rsa_github_readonly_deploy_key /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# clone repo into image
RUN git clone git@github.com:bugblatter2016/r10k-bastion-testing.git