#!/bin/bash

apt-get install --yes --force-yes python python-jenkins python-jenkinsapi

function wait_for_jenkins() {
  while [[ $(curl -sL -w "%{http_code}\\n" "http://jenkins-beta.service.lhr.consul:8080" -o /dev/null) != '200' ]]
  do
    echo 'Jenkins not up yet'
    sleep 5
  done
  echo 'Jenkins up and running'
}

function restart_and_wait_for_jenkins() {
  echo Restarting Jenkins
  curl -XPOST http://jenkins-beta.service.lhr.consul:8080/safeRestart
  wait_for_jenkins
}

wait_for_jenkins

echo Plugin install started
pushd plugins
sleeptime=30
while [[ /bin/true ]]
do
  python jenkins_plugins.py
  sleeptime=$(($sleeptime + $sleeptime))
  echo waiting for $sleeptime before re-checking plugins
  sleep $sleeptime
  python jenkins_check_plugins.py
  if [[ $(python jenkins_check_plugins.py | tail -1) = 'OK' ]]
  then
    break
  fi
  restart_and_wait_for_jenkins
done
restart_and_wait_for_jenkins
popd
echo Plugin install complete

