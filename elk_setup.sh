#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage $0 <localhost_name_or_ip>"
    exit 1
fi

# prevents trying to access stdin
export DEBIAN_FRONTEND=noninteractive

# update apt stuff
apt-get update

# install git
apt-get -y install git

# install java7
apt-get -y install openjdk-8-jre

# set java_home for all!
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment

# download and install elastic public key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# install transport-https and repository definition
apt-get -y install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

# install elasticsearch and kibana
apt-get update && apt-get install -y elasticsearch && apt-get install -y kibana

# config elasticsearch
echo "cluster.name: escluster" >> /etc/elasticsearch/elasticsearch.yml
echo "node.name: esnode" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: \"${1}\"" >> /etc/elasticsearch/elasticsearch.yml

# config kibana
echo "server.host: \"${1}\"" >> /etc/kibana/kibana.yml
echo "elasticsearch.url: \"http://${1}:9200\""

# reload systemd configs, enable, and start elasticsearch and kibana
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl enable kibana.service
systemctl start elasticsearch
systemctl start kibana

exit 0
