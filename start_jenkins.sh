#!/bin/bash

export VAULT_ADDR=https://vault.service.lhr.consul:8200
echo "Assuming Vault binary doesn't exist, download it"
curl --retry 3 -o vault.zip https://releases.hashicorp.com/vault/0.7.0/vault_0.7.0_linux_arm.zip && yes | unzip vault.zip 
echo "Get GitHub PAN from Vault"
export GITHUB_PAN=$(./vault read -field=pan secret/github)
export JENKINS_SLAVE_AGENT_PORT=${SLAVE_AGENT_PORT:-"5050"}
export JENKINS_HOME=/alloc/data/jenkins
JENKINS_ARGS="--httpPort=$HTTP_PORT"
VERSION=${JENKINS_VERSION:-"2.46.2"}
URL="http://ftp-chi.osuosl.org/pub/jenkins/war-stable/${VERSION}/jenkins.war"
ARGS=${JAVA_ARGS:-"-Xmx768m -Xms384m"}
echo "Prepare Jenkins Home"
test -d ${JENKINS_HOME}/.git || rm -rf ${JENKINS_HOME} && mkdir ${JENKINS_HOME} && git clone https://${GITHUB_PAN}@github.com/ncorrare/jenkins-config.git ${JENKINS_HOME}
echo "Get Jenkins WAR"
curl -o /tmp/jenkins.war ${URL}

java $ARGS -jar /tmp/jenkins.war $JENKINS_ARGS
