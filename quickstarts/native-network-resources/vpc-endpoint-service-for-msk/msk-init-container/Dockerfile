FROM amazonlinux
USER root

ENV KAFKA_VERSION=3.0.0 
ENV KAFKA_URL=https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz
ENV KAFKA_TMP_DEST=/opt/kafka.tgz
ENV KAFKA_WORKDIR=/opt/kafka

RUN yum -y install java
RUN yum -y install tar
RUN yum -y install wget
RUN yum -y install gzip

RUN cp $(readlink -f /usr/bin/java | sed "s:bin/java::")lib/security/cacerts \
    /opt/kafka.client.truststore.jks 
     
RUN wget $KAFKA_URL -O ${KAFKA_TMP_DEST} && \
    mkdir -p ${KAFKA_WORKDIR} && \
    tar -xzf ${KAFKA_TMP_DEST} --strip-components=1 -C ${KAFKA_WORKDIR} && \
    rm -rf ${KAFKA_TMP_DEST}
   
COPY client.properties /opt/client.properties
COPY configure-brokers.sh /opt/configure-brokers.sh