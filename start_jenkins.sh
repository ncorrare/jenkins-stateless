!#/bin/bash

curl -o vault.zip https://releases.hashicorp.com/vault/0.7.0/vault_0.7.0_linux_arm.zip ; yes | unzip vault.zip
GITHUB_PAN=$(./vault read -field=pan secret/github)
JENKINS_HOME=/local/jenkins
JENKINS_ARGS="--httpPort=$HTTP_PORT --ajp13Port=$AJP_PORT"
JENKINS_ARGS="$JENKINS_ARGS --preferredClassLoader=java.net.URLClassLoader"
VERSION=${JENKINS_VERSION:-"2.46.2"}
URL="http://ftp-chi.osuosl.org/pub/jenkins/war-stable/${VERSION}/jenkins.war"
ARGS=${JAVA_ARGS:-"-Xmx768m -Xms384m"}
git clone https://${GITHUB_PAN}@github.com/ncorrare/jenkins-config.git ${JENKINS_HOME}
curl -O /tmp/jenkins.war ${URL}

java $ARGS -jar /tmp/jenkins.war $JENKINS_ARGS
