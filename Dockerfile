FROM jenkins/jenkins:2.121.1
MAINTAINER Steve de Silva <steve.desilva@gmail.com>

# Suppress apt installation warnings
ENV DEBIAN_FRONTEND=noninteractive

# Change to root user
USER root

# Used to set the docker group ID
# Set to 497 by default, which is the group ID used by AWS Linux ECS Instance
ARG DOCKER_GID=497

# Create Docker Group with GID
# Set default value of 497 if DOCKER_GID set to blank string by Docker Compose
RUN groupadd -g ${DOCKER_GID:-497} docker

# Used to control Docker and Docker Compose versions installed
# NOTE: As of February 2016, AWS Linux ECS only supports Docker 1.9.1
ARG DOCKER_ENGINE=1.10.2
# ARG DOCKER_COMPOSE=1.6.2
ARG DOCKER_COMPOSE=1.21.0


# Install base packages
RUN apt-get update -y && \
    apt-get install apt-transport-https curl python-dev python-setuptools \
    software-properties-common gcc make libssl-dev -y --no-install-recommends && \
    easy_install pip

# RUN apt-get update -y

# RUN apt-get install -y --no-install-recommends \
#     apt-transport-https \
#     curl \
#     software-properties-common 

RUN curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | apt-key add -


RUN add-apt-repository \
   "deb https://packages.docker.com/1.13/apt/repo/ \
   ubuntu-trusty \
   main"

RUN echo 'deb http://cz.archive.ubuntu.com/  trusty main' >> /etc/apt/sources.list.d/docker.list

RUN apt-get update



# RUN apt-get -y --allow-unauthenticated install docker-ce && \
#     usermod -aG docker jenkins && \
#     usermod -aG users jenkins

RUN apt-get -y --allow-unauthenticated install docker-engine && \
    usermod -aG staff,docker jenkins && \
    usermod -aG users jenkins

# Install Docker Compose
RUN pip install docker-compose && \
    pip install ansible boto boto3

# Change to jenkins user
USER jenkins

# Add Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

