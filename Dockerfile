# Pull base image
FROM ubuntu:14.04
MAINTAINER Junhyeok Choi <junhyeok.choi@gmail.com>

ENV SCALA_VERSION 2.11.7
ENV SBT_VERSION 0.13.8

# Install required software for building docker image
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget

# Install Java 8
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSION_MAJOR}-oracle

# Auto-accept license agreement
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen   true | debconf-set-selections

# Add WebUpd8 PPA and install JRE/JDK, then clean up
RUN \
  add-apt-repository ppa:webupd8team/java && \
  apt-get update && \
  apt-get -qy install oracle-java${JAVA_VERSION_MAJOR}-installer && \
  apt-get clean && \
  rm -rf /tmp/* /var/tmp/* /var/lib/apt/archive/* /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-{jre,jdk}*-installer

ENV PATH ${PATH}:${JAVA_HOME}/bin

# Install Scala
RUN \
  cd /root && \
  curl -o scala-$SCALA_VERSION.tgz http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz && \
  tar -xf scala-$SCALA_VERSION.tgz && \
  rm scala-$SCALA_VERSION.tgz && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install SBT
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt
