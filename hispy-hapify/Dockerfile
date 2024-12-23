FROM tomcat:9.0.68-jre17-temurin-focal

LABEL version="2.0" \
      maintainer="jtsaich" \
      description="The tomcat image for PY_HIS Server"

COPY siciap.cer /usr/local/tomcat/siciap.cer

# Copy the APM agent JAR into the container
RUN mkdir /usr/local/apm/ && curl "https://oss.sonatype.org/service/local/repositories/snapshots/content/co/elastic/apm/elastic-apm-agent/1.49.1-SNAPSHOT/elastic-apm-agent-1.49.1-20240429.100006-21.jar" -o /usr/local/apm/elastic-apm-agent.jar
ENV ELASTIC_APM_SERVER_URL=http://localhost:8200
ENV ELASTIC_APM_ENVIRONMENT=histesting

RUN keytool -import -noprompt -trustcacerts -alias siciap \
            -file /usr/local/tomcat/siciap.cer \
            -storepass changeit \
            -keystore /opt/java/openjdk/lib/security/cacerts
