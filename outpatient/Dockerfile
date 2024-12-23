#FROM tomcat:9.0.39-jdk8-openjdk-slim-buster
FROM tomcat:9.0.68-jre8-temurin-focal

LABEL version="3.1" \
      maintainer="walker088 and tawhk" \
      description="The tomcat image for PY_HIS Server"

ARG TOMCAT_WORKSPACE=/usr/local/tomcat
RUN mv $TOMCAT_WORKSPACE/webapps.dist/manager $TOMCAT_WORKSPACE/webapps/outhis-manager
RUN mkdir -p $TOMCAT_WORKSPACE/images

COPY manager_context.xml $TOMCAT_WORKSPACE/webapps/outhis-manager/META-INF/context.xml
COPY tomcat-users.xml $TOMCAT_WORKSPACE/conf/tomcat-users.xml
COPY server.xml $TOMCAT_WORKSPACE/conf/server.xml
COPY web.xml $TOMCAT_WORKSPACE/conf/web.xml
COPY siciap.cer $TOMCAT_WORKSPACE/siciap.cer

# Copy the APM agent JAR into the container
RUN mkdir /usr/local/apm/ && curl "https://oss.sonatype.org/service/local/repositories/snapshots/content/co/elastic/apm/elastic-apm-agent/1.49.1-SNAPSHOT/elastic-apm-agent-1.49.1-20240429.100006-21.jar" -o /usr/local/apm/elastic-apm-agent.jar
ENV ELASTIC_APM_SERVER_URL=http://localhost:8200
ENV ELASTIC_APM_ENVIRONMENT=histesting

RUN keytool -import -noprompt -trustcacerts -alias siciap \
            -file /usr/local/tomcat/siciap.cer \
            -storepass changeit \
            #-keystore  /usr/local/openjdk-8/jre/lib/security/cacerts
            -keystore /opt/java/openjdk/lib/security/cacerts
