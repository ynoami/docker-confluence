FROM ubuntu:latest

MAINTAINER ynoami<nyata100@gmail.com>

RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update -y
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN apt-get install -y oracle-java8-installer 

RUN apt-get install -y wget
RUN wget https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-5.9.10.tar.gz

RUN mkdir -p /opt/atlassian
RUN tar -zxvf atlassian-confluence-5.9.10.tar.gz -C /opt/atlassian
RUN rm atlassian-confluence-5.9.10.tar.gz

RUN useradd --create-home --comment "Account for running Confluence" --shell /bin/bash confadmin

RUN chown -R confadmin /opt/atlassian/atlassian-confluence-5.9.10/
RUN chgrp -R confadmin /opt/atlassian/atlassian-confluence-5.9.10/

RUN echo -e "\nconfluence.home=/var/atlassian/application-data/confluence" >> /opt/atlassian/atlassian-confluence-5.9.10/confluence/WEB-INF/classes/confluence-init.properties

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV CONF_USER confadmin

ENTRYPOINT ["/opt/atlassian/atlassian-confluence-5.9.10/bin/start-confluence.sh", "-fg"]
