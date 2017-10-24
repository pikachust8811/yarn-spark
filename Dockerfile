FROM pjfanning/docker-hadoop-jdk8:2.7.1

RUN yum clean all && \
    rpm --rebuilddb && \
    yum install -y wget

RUN wget https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz -O /tmp/spark.tgz && \
    tar xf /tmp/spark.tgz -C /usr/local/ && \
    ln -s /usr/local/spark-2.2.0-bin-hadoop2.7 /usr/local/spark

COPY config/core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml

COPY config/yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

ENV HADOOP_HOME $HADOOP_PREFIX
ENV YARN_HOME $HADOOP_PREFIX

ENV SPARK_HOME /usr/local/spark

COPY config/spark* /usr/local/spark/conf/

CMD ["/bin/bash"]
