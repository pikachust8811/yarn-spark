FROM centos:7

RUN yum install -y which

RUN yum install -y java-1.8.0-openjdk-devel.x86_64 && \
    ln -s $(dirname $(dirname $(dirname $(readlink -f /usr/bin/java)))) /usr/local/java
ENV JAVA_HOME=/usr/local/java \
    PATH=$PATH:$JAVA_HOME/bin

RUN curl -s http://apache.stu.edu.tw/hadoop/common/hadoop-2.7.5/hadoop-2.7.5.tar.gz | \
    tar -xz -C /usr/local/ && \
    ln -s /usr/local/hadoop-2.7.5 /usr/local/hadoop
ENV HADOOP_PREFIX=/usr/local/hadoop \
    HADOOP_COMMON_HOME=/usr/local/hadoop \
    HADOOP_HDFS_HOME=/usr/local/hadoop \
    HADOOP_MAPRED_HOME=/usr/local/hadoop \
    HADOOP_YARN_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
    YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop

COPY config/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
COPY config/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml

RUN /usr/local/hadoop/bin/hdfs namenode -format -force -nonInteractive -clusterId CID-8f4a74c5-c3bf-454b-98a4-544eaba3abc5

COPY config/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
COPY config/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml

RUN curl -s https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz | \
    tar -xz -C /usr/local/ && \
    ln -s /usr/local/spark-2.2.0-bin-hadoop2.7 /usr/local/spark
ENV SPARK_HOME=/usr/local/spark \
    PATH=$PATH:$SPARK_HOME/bin

COPY config/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf
COPY config/spark-env.sh /usr/local/spark/conf/spark-env.sh

RUN find /usr/local/hadoop/ -type f -name "netty-[0-9]*.[0-9]*.[0-9]*.Final.jar" -exec mv '{}' '{}'.bak \; -exec bash -c 'cp /usr/local/spark/jars/netty-[0-9]*.[0-9]*.[0-9]*.Final.jar $(dirname {})' \;
RUN find /usr/local/hadoop/ -type f -name "netty-all-[0-9]*.[0-9]*.[0-9]*.Final.jar" -exec mv '{}' '{}'.bak \; -exec bash -c 'cp /usr/local/spark/jars/netty-all-[0-9]*.[0-9]*.[0-9]*.Final.jar $(dirname {})' \;

EXPOSE 50070
EXPOSE 50075
EXPOSE 9000
EXPOSE 50010
EXPOSE 50020
EXPOSE 50090
EXPOSE 8020
EXPOSE 9000
EXPOSE 19888
EXPOSE 8030-8033
EXPOSE 8040
EXPOSE 8042
EXPOSE 8088
EXPOSE 31000-31100
EXPOSE 49707
EXPOSE 2122

COPY bootstrap.sh /etc/bootstrap.sh

RUN chmod +x /usr/local/hadoop/etc/hadoop/*.sh && \
    chmod +x /usr/local/spark/conf/*.sh

CMD ["/etc/bootstrap.sh", "-bash"]
