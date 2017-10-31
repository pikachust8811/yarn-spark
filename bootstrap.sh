#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

if [ "$NODE_TYPE" == "master" ]; then
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
  $HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager

  $HADOOP_PREFIX/bin/hadoop fs -mkdir -p /user/spark/events
  $SPARK_HOME/sbin/start-history-server.sh
else
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
  $HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager
fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
