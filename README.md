# Spark on Yarn Docker
This project focus on creating Spark on Yarn nodes, for master/slave and driver.

# Docker Hub
[ire7715/yarn-spark](https://hub.docker.com/r/ire7715/yarn-spark/)

# Mannual Settings
## Driver Nodes
1. Set the "`spark.eventLog.enabled` to `true`" and "the host name of `spark.eventLog.dir` to your master node" in `/usr/local/spark/conf/spark-default.xml`
