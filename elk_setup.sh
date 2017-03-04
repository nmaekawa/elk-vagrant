#!/bin/bash
# pass through env vars
# $LOCALHOST_IP
# $ES_2 non-zero means elasticsearch 2, 5 otherwise

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
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -


# install transport-https
apt-get -y install apt-transport-https

if [ -n "${ES_2}" ]; then  # es2
    # save repository definition
    echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
    echo "deb https://packages.elastic.co/kibana/4.6/debian stable main" | sudo tee -a /etc/apt/sources.list.d/kibana.list

    # install elasticsearch and kibana
    apt-get update && apt-get install -y elasticsearch=2.4.1 && apt-get install -y kibana=4.6.2

    # config files for kibana
    KIBANA_CONFIG_FILE="/opt/kibana/config/kibana.yml"

else  # es5
    # save repository definition
    echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list

    # install elasticsearch and kibana
    apt-get update && apt-get install -y elasticsearch && apt-get install -y kibana

    # config files for kibana
    KIBANA_CONFIG_FILE="/etc/kibana/kibana.yml"
fi


echo "--------------------------------------"
echo "${KIBANA_CONFIG_FILE}"
echo "--------------------------------------"

# config elasticsearch
echo "cluster.name: escluster" >> /etc/elasticsearch/elasticsearch.yml
echo "node.name: esnode" >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: \"${LOCALHOST_IP}\"" >> /etc/elasticsearch/elasticsearch.yml

# config kibana
echo "server.host: \"${LOCALHOST_IP}\"" >> ${KIBANA_CONFIG_FILE}
echo "elasticsearch.url: \"http://${LOCALHOST_IP}:9200\"" >> ${KIBANA_CONFIG_FILE}

# reload systemd configs, enable, and start elasticsearch and kibana
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl enable kibana.service
systemctl start elasticsearch
systemctl start kibana

exit 0
