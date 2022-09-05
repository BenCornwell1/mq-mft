#!/bin/bash

# The startup script for the agent in the container.
#
# First it has to creates some of the required folders needed as described in
# the docs based on the agent property files.
#
# The first option is the name of the coordination queue manager.
# 
# The second is the name of the agent.  This must be described in its
# own properties file, it must be supplied in the properties config map and
# mapped into the agent pods.
#
# Refer to the below link for details of the directory structure:
#
# https://www.ibm.com/docs/en/ibm-mq/9.3?topic=use-creating-mq-file-transfer-structure
#
# ..then it runs the agent.  It is intended to be run as the command in the pod.

coordinationQMName=$1
agentName=$2

if [ -z $coordinationQMName ] || [ -z $agentName ] 
then
    echo "Usage: startup <coordination QM name> <agent name>"
    sleep 30
    exit 1
fi

mkdir /var/mqm/mqft/logs/$coordinationQMName
mkdir /var/mqm/mqft/logs/$coordinationQMName/agents
mkdir /var/mqm/mqft/logs/$coordinationQMName/agents/$agentName

chmod -R 744 /var/mqm/mqft/logs/$coordinationQMName

echo Staring agent $agentName
/opt/mqm/bin/fteStartAgent -F $agentName