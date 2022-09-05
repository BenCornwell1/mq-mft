FROM quay.io/centos/centos:stream9
ARG INSTALL_FILE
ADD $INSTALL_FILE /tmp/mq/
WORKDIR /tmp/mq/MQServer
RUN ./mqlicense.sh -accept
RUN yum install -y util-linux
RUN rpm -Uvh \
    MQSeriesGSKit-9.3.0-0.x86_64.rpm \
    MQSeriesRuntime-9.3.0-0.x86_64.rpm \
    MQSeriesJRE-9.3.0-0.x86_64.rpm \
    MQSeriesJava-9.3.0-0.x86_64.rpm \
    MQSeriesServer-9.3.0-0.x86_64.rpm \
    MQSeriesSamples-9.3.0-0.x86_64.rpm \
    MQSeriesClient-9.3.0-0.x86_64.rpm \
    MQSeriesFTBase-9.3.0-0.x86_64.rpm \
    MQSeriesFTAgent-9.3.0-0.x86_64.rpm \
    MQSeriesFTService-9.3.0-0.x86_64.rpm \
    MQSeriesFTTools-9.3.0-0.x86_64.rpm
RUN rm -rf /tmp/mq
COPY startup.sh /var/mqm/
RUN chmod 775 /var/mqm/startup.sh



