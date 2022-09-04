FROM quay.io/centos/centos:stream9
ADD IBM_MQ* /tmp/mq/
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
RUN mkdir /var/mqm/mqft/logs/COORD
RUN mkdir /var/mqm/mqft/logs/COORD/agents
RUN mkdir /var/mqm/mqft/logs/COORD/agents/SOURCE
RUN mkdir /var/mqm/mqft/logs/COORD/agents/DEST
RUN chmod -R 777 /var/mqm/mqft/logs/COORD/

