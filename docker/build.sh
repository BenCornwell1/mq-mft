#!/bin/bash

#docker build -t uk.icr.io/mq-mft/mq-mft:latest --build-arg INSTALL_FILE="$(pwd)/../../IBM_MQ_9.3_LINUX_X86-64.tar.gz" .
docker build -t uk.icr.io/mq-mft/mq-mft:latest --build-arg INSTALL_FILE='IBM_MQ_9.3_LINUX_X86-64.tar.gz' .

if [ $? -eq 0 ]
then
    echo Pushing to remote repo
    docker push uk.icr.io/mq-mft/mq-mft:latest
else
    echo Docker build failed.
fi