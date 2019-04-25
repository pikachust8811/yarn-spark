#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
$HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager
$HADOOP_PREFIX/bin/hadoop fs -mkdir -p /user/spark/events
$SPARK_HOME/sbin/start-history-server.sh
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
$HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager

echo "spark.driver.bindAddress "$HOSTNAME >> /usr/local/spark/conf/spark-defaults.conf
echo "spark.driver.host "$MASTER_HOSTNAME >> /usr/local/spark/conf/spark-defaults.conf

sed -i 's/master/'$MASTER_HOSTNAME'/' /usr/local/hadoop/etc/hadoop/core-site.xml
sed -i 's/master/'$MASTER_HOSTNAME'/' /usr/local/hadoop/etc/hadoop/yarn-site.xml

sed -i 's/JUPYTER_AUTH_TOKEN/'$JUPYTER_AUTH_TOKEN'/' /root/.jupyter/jupyter_notebook_config.py
jupyter notebook --allow-root >> /var/log/jupyter.log

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
