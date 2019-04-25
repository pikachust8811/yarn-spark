FROM centos:7

# install which
RUN yum install -y which

# install java-jdk
RUN yum install -y java-1.8.0-openjdk-devel.x86_64 && \
  ln -s $(dirname $(dirname $(dirname $(readlink -f /usr/bin/java)))) /usr/local/java
ENV JAVA_HOME=/usr/local/java \
  PATH=$PATH:$JAVA_HOME/bin

# install scala
RUN curl -s -o /tmp/scala-2.11.12.rpm https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.rpm && \
  yum install -y /tmp/scala-2.11.12.rpm

# install python3.6
RUN yum install -y epel-release && \
  yum install -y python36 && \
  curl -s -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
  python36 /tmp/get-pip.py
ENV PYSPARK_PYTHON=python3.6 \
  PYTHONPATH=/usr/local/spark/python/:/usr/local/spark/python/lib/py4j-0.10.7-src.zip

# install hadoop
RUN curl -s http://apache.stu.edu.tw/hadoop/common/hadoop-2.9.0/hadoop-2.9.0.tar.gz | \
  tar -xz -C /usr/local/ && \
  ln -s /usr/local/hadoop-2.9.0 /usr/local/hadoop
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

# install spark
RUN curl -s http://ftp.tc.edu.tw/pub/Apache/spark/spark-2.4.1/spark-2.4.1-bin-hadoop2.7.tgz | \
  tar -xz -C /usr/local/ && \
  ln -s /usr/local/spark-2.4.1-bin-hadoop2.7 /usr/local/spark
ENV SPARK_HOME=/usr/local/spark \
  PATH=$PATH:$SPARK_HOME/bin

COPY config/spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf
COPY config/spark-env.sh /usr/local/spark/conf/spark-env.sh

RUN find /usr/local/hadoop/ -type f -name "netty-[0-9]*.[0-9]*.[0-9]*.Final.jar" -exec mv '{}' '{}'.bak \; -exec bash -c 'cp /usr/local/spark/jars/netty-[0-9]*.[0-9]*.[0-9]*.Final.jar $(dirname {})' \;
RUN find /usr/local/hadoop/ -type f -name "netty-all-[0-9]*.[0-9]*.[0-9]*.Final.jar" -exec mv '{}' '{}'.bak \; -exec bash -c 'cp /usr/local/spark/jars/netty-all-[0-9]*.[0-9]*.[0-9]*.Final.jar $(dirname {})' \;
RUN find /usr/local/hadoop/ -type f -name "commons-lang3-[0-9]*.[0-9]*.jar" -exec mv '{}' '{}'.bak \; -exec bash -c 'cp /usr/local/spark/jars/commons-lang3-[0-9]*.[0-9]*.jar $(dirname {})' \;

# install jupyter
RUN pip3 install jupyter && \
  pip3 install toree && \
  jupyter toree install --spark_home=/usr/local/spark

RUN jupyter notebook --generate-config && \
  echo "c.Application.log_level = 'DEBUG'" >> ~/.jupyter/jupyter_notebook_config.py && \
  echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py && \
  echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py && \
  echo "c.NotebookApp.port = 8888" >> ~/.jupyter/jupyter_notebook_config.py && \
  echo "c.NotebookApp.token = u'JUPYTER_AUTH_TOKEN'" >> ~/.jupyter/jupyter_notebook_config.py && \
  echo "c.NotebookApp.notebook_dir = '/data/jupyter'" >> ~/.jupyter/jupyter_notebook_config.py && \
  echo "c.FileContentsManager.delete_to_trash = False" >> ~/.jupyter/jupyter_notebook_config.py && \
  mkdir /data/jupyter

COPY bootstrap.sh /etc/bootstrap.sh

RUN chmod +x /usr/local/hadoop/etc/hadoop/*.sh && \
  chmod +x /usr/local/spark/conf/*.sh

CMD ["/etc/bootstrap.sh", "-bash"]
