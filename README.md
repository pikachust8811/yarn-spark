# Spark on Yarn Docker
This project focus on creating Spark on Yarn nodes, for master/slave and driver.

----
# Docker Hub
[ire7715/yarn-spark](https://hub.docker.com/r/ire7715/yarn-spark/)

----
# Usage
## Build an Image
`docker build -t yarn-spark:${VERSION} .`
## Pull an Iamge
`docker pull ire7715/yarn-spark:${VERSION}`
## Run a Conatiner
> Volume is recommended, so you won't loose your data once after the container deleted.
````
docker volume create hdfs-data
docker run -d --name yarn-spark-${NUMBER} \
  --mount source=hdfs-data,target=/hdfs-data \
  ire7715/yarn-spark:${VERSION}
````

----
# Mannual Settings
## Assumptions
1. All nodes assume the master node is named **master**

## All nodes
1. Set **yarn.resourcemanager.hostname** and **yarn.timeline-service.hostname** to your master node in  `/usr/local/hadoop/etc/hadoop/yarn-site.xml`
2. Set **fs.defaultFS** to your master node in `/usr/local/hadoop/etc/hadoop/core-site.xml`

## Master Node
1. Set environment variable with `docker run -e "NODE_TYPE=master" ...` on master node, so the **/etc/bootstrap.sh** can execute the corresponding scripts for master node.

## Slave Node
1. Set environment variable with `docker run -e "NODE_TYPE=slave" ...` on master node, so the **/etc/bootstrap.sh** can execute the corresponding scripts for master node.

## Driver Nodes
1. Set the **spark.eventLog.enabled** to **true** in `/usr/local/spark/conf/spark-default.xml`
2. Set the host name of **spark.eventLog.dir** to your master node in `/usr/local/spark/conf/spark-default.xml`
