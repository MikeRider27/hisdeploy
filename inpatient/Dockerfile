FROM tomcat:9.0.68-jre17-temurin-focal

LABEL version="2.1" \
      maintainer="walker088 and tawhk" \
      description="The tomcat image for HIS internacion Server"

#ARG DOCKER_USER=container
#ARG DOCKER_USER_UID=2000
#ARG DOCKER_USER_GID=2000
ARG TOMCAT_WORKSPACE=/usr/local/tomcat

RUN mv $TOMCAT_WORKSPACE/webapps.dist/manager $TOMCAT_WORKSPACE/webapps/interhis-manager
RUN mkdir -p $TOMCAT_WORKSPACE/images

COPY manager_context.xml $TOMCAT_WORKSPACE/webapps/interhis-manager/META-INF/context.xml
COPY tomcat-users.xml $TOMCAT_WORKSPACE/conf/tomcat-users.xml
COPY server.xml $TOMCAT_WORKSPACE/conf/server.xml
COPY web.xml $TOMCAT_WORKSPACE/conf/web.xml
COPY siciap.cer $TOMCAT_WORKSPACE/siciap.cer

# Copy the APM agent JAR into the container
RUN mkdir /usr/local/apm/ && curl "https://oss.sonatype.org/service/local/repositories/snapshots/content/co/elastic/apm/elastic-apm-agent/1.49.1-SNAPSHOT/elastic-apm-agent-1.49.1-20240429.100006-21.jar" -o /usr/local/apm/elastic-apm-agent.jar
ENV ELASTIC_APM_SERVER_URL=http://localhost:8200
ENV ELASTIC_APM_ENVIRONMENT=histesting

RUN keytool -import -noprompt -trustcacerts -alias siciap \
            -file $TOMCAT_WORKSPACE/siciap.cer \
            -storepass changeit \
            -keystore /opt/java/openjdk/lib/security/cacerts

#RUN groupadd -g $DOCKER_USER_GID $DOCKER_USER
#RUN useradd -u $DOCKER_USER_UID -g $DOCKER_USER_GID $DOCKER_USER

#RUN chown -R $DOCKER_USER_UID:$DOCKER_USER_GID $TOMCAT_WORKSPACE

#USER $DOCKER_USER
