FROM ynoami/java:java8

MAINTAINER ynoami<nyata100@gmail.com>

RUN useradd --create-home --comment "Account for running Confluence" --shell /bin/bash confadmin

RUN apt-get install -y wget
RUN mkdir -p /opt/atlassian

RUN wget https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-5.9.10.tar.gz \
    && tar -zxvf atlassian-confluence-5.9.10.tar.gz -C /opt/atlassian \
    && rm atlassian-confluence-5.9.10.tar.gz \
    && chown -R confadmin /opt/atlassian/atlassian-confluence-5.9.10/ \
    && chgrp -R confadmin /opt/atlassian/atlassian-confluence-5.9.10/

RUN echo -e "\nconfluence.home=/var/atlassian/application-data/confluence" >> /opt/atlassian/atlassian-confluence-5.9.10/confluence/WEB-INF/classes/confluence-init.properties

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV CONF_USER confadmin

# bug fix ... tofu
RUN wget https://maven.atlassian.com/service/local/repositories/atlassian-public/content/com/atlassian/plugins/document-conversion-library/1.2.12/document-conversion-library-1.2.12.jar -O /opt/atlassian/atlassian-confluence-5.9.10/confluence/WEB-INF/atlassian-bundled-plugins/document-conversion-library-1.2.12.jar
RUN rm /opt/atlassian/atlassian-confluence-5.9.10/confluence/WEB-INF/atlassian-bundled-plugins/document-conversion-library-1.2.14.jar
RUN sed -i -e "43a CATALINA_OPTS=\"-Dconfluence.document.conversion.fontpath=/var/atlassian/application-data/confluence/fonts \${CATALINA_OPTS}\"" /opt/atlassian/atlassian-confluence-5.9.10/bin/setenv.sh

ENTRYPOINT ["/opt/atlassian/atlassian-confluence-5.9.10/bin/start-confluence.sh", "-fg"]
