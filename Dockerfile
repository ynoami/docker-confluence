FROM ynoami/java:java8

MAINTAINER ynoami<nyata100@gmail.com>

RUN useradd --create-home --comment "Account for running Confluence" --shell /bin/bash confadmin

RUN apt-get install -y wget
RUN mkdir -p /opt/atlassian

ENV CONF_VERSION 5.9.10

RUN wget https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${CONF_VERSION}.tar.gz \
    && tar -zxvf atlassian-confluence-${CONF_VERSION}.tar.gz -C /opt/atlassian \
    && rm atlassian-confluence-${CONF_VERSION}.tar.gz \
    && chown -R confadmin /opt/atlassian/atlassian-confluence-${CONF_VERSION}/ \
    && chgrp -R confadmin /opt/atlassian/atlassian-confluence-${CONF_VERSION}/

RUN echo -e "\nconfluence.home=/var/atlassian/application-data/confluence" >> /opt/atlassian/atlassian-confluence-${CONF_VERSION}/confluence/WEB-INF/classes/confluence-init.properties

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV CONF_USER confadmin

# bug fix ... tofu
RUN wget https://maven.atlassian.com/service/local/repositories/atlassian-public/content/com/atlassian/plugins/document-conversion-library/1.2.12/document-conversion-library-1.2.12.jar -O /opt/atlassian/atlassian-confluence-${CONF_VERSION}/confluence/WEB-INF/atlassian-bundled-plugins/document-conversion-library-1.2.12.jar
RUN rm /opt/atlassian/atlassian-confluence-${CONF_VERSION}/confluence/WEB-INF/atlassian-bundled-plugins/document-conversion-library-1.2.14.jar
RUN sed -i -e "43a CATALINA_OPTS=\"-Dconfluence.document.conversion.fontpath=/var/atlassian/application-data/confluence/fonts \${CATALINA_OPTS}\"" /opt/atlassian/atlassian-confluence-${CONF_VERSION}/bin/setenv.sh

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
