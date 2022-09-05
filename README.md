# MQ MFT in CP4I

**Please note, the deployment instructions are at the end of this document.  The explanation comes first.**
## Introduction

MQ MFT is not part of the standard IBM CP4I image for MQ. However, you can build your own container and MQ is supported if you do that.  This repository is an example of how this could be done.  It is not supported by IBM and is for demonstration purposes only.

In this example, there are two agents - source and destination.  Each has its own queue manager, and there is one command QM and one coordination QM.  All four are deployed independently as standalone QMs via CP4I.  This means that they need TCP connections and channels between them, and the associated transmit queues. This diagram shows the channels connecting them and their names. The naming convention is FROM.TO denoting the QM that the channel goes from and to.

![MFT Network](/images/MFT-MQ-network.png)

## Container architecture

MFT agents themselves have configuration files in the following tree structure:


    MQ_DATA_PATH/mqft/
        config/
        coordination_qmgr_name/
                coordination.properties
                command.properties
                agents/
                agent_name/
                        agent.properties
                        exits
                loggers/
                logger_name
                        logger.properties
        installations/
        installation_name/
                installation.properties

(from https://www.ibm.com/docs/en/ibm-mq/9.1?topic=transfer-mft-configuration-options-multiplatforms)

When running the agent in a container, these configuration files are stored in a ConfigMap - in this example it's called mftproperties. It contains the property files for all the queue managers, however only the relevant ones are mapped into each pod for the source or destination agents.

The other ConfigMap is called mftconfig, and these files contain the MQSC commands to set up each queue manager.  They are referenced from the QueueManager CRD that you use to create QMs in CP4I.

The source and destination agent are created with their own YAML files (in this case as Deployments, although they could be just Pods as they do not support scaling).  The Pod definition references an image pull secret that contains a key that will grant read-only access to an IBM container registry location for this image only.  The property files are mapped into specific directories which bear the names of the agents.  The container also contains a startup script that will create some directories - this script needs to be run as the command of the pod, with the coordination QM name and the agent name as parameters.

The MQSC files for the queue managers contain the queue definitions, the transmit queue definitions, and the channels to communicate with each other.

## Customising the Deployment

 ### Building the image

 The Docker file does the MQ installation. It needs the MQ installation file (that you downloadd from Passport Advantage) as a build argument.  This file must be in the same folder or lower as the Docker file - it cannot be in a higher directory as per Docker restrictions.

'docker\build.sh'

This is a simple script to build and push the file.  To use it you will need to change the repository and make sure the build argument points to the MQ installation file.

`docker\Dockerfile`

The Docker file does the following:

    1. Adds and unpacks the installation bundle and copy it into /tmp
    2. Accepts the license
    3. Installs util-linux package via yum to provide the su command.
    4. Installs the MQ package using rpm.
    5. Removes the installation files
    6. Copies the startup script into /var/mqm and makes it executable.

`docker\startup.sh`

Finally the startup script creates the agent config file directories.

### Customising the Agent Deployments

There are two sample YAMLs here that deploy a source and a destination agent.  You can deploy as many agents as you want using this pattern.  The important parts of the YAML are as follows:

        volumes:
        - name: agent-properties
          configMap:
            name: mftproperties
            items:
              - key: source-agent.properties
                path: agent.properties
        - name: command-coord-properties
          configMap:
            name: mftproperties
            items:               
              - key: command.properties
                path: command.properties
              - key: coord.properties
                path: coordination.properties
        - name: installation-properties
          configMap:
            name: mftproperties
            items:
              - key: installation.properties
                path: installation.properties

Each agent will need the command and coordination properties files, and its own agent configuration file.  The command and coordination details will be the same, but the agent property files are specific to each agent.  In this example the property files are all in the same ConfigMap but this is not essential.  The file is called `properties.yaml`

The volmes are mapped into the correct directory structure for the agent process as follows:

          volumeMounts:
            - name: agent-properties
              mountPath: /var/mqm/mqft/config/COORD/agents/SOURCE
            - name: command-coord-properties
              mountPath: /var/mqm/mqft/config/COORD/
            - name: installation-properties
              mountPath: /var/mqm/mqft/installations/Installation1

The name of this agent is SOURCE so the agent properties file is mapped into a directory called SOURCE.  The installation name is the same as the coordination queue manager and is in this case called COORD.

The startup command takes two arguments - the coordination QM name and the agent name.

          command: ["/var/mqm/startup.sh", "COORD", "SOURCE"]

The security context requires fsGroup to be set to 1000 which is the mqm group in this container.  This will require appropriate SCCs to be set.  This was tested with the privileged SCC applied to the default user in the namespace.

      securityContext:
        runAsUser: 998
        fsGroup: 1000

This example was tested with temporary files creaed in the container.  Howver, to be useful you will need to map some kind of persistent volume to the pod which will host the files to be transferred and to act as a receiving location.

### Customising the Queue Managers
Decide how many queue managers you need, and create QueueManager CRDs for each one.  In this example, the file is called `qms.yaml` and contains four.  In each CRD, the MQSC commands to configure the QM are mapped from a ConfigMap, in this case called mftconfig which is defined in `config.yaml`.

Other customisations are available e.g. using persistent storage instead of ephemeral, as here.  Refer to the CP4I documentation for more informatino.

## Deployment Process
This example can be deployed as follows:

    1. Customise the files as above
    2. Deploy the ConfigMaps, e.g.

        oc apply -f properties.yaml config.yaml
    
    3. Deploy the QMs e.g. 

        oc apply -f qms.yaml

    4. Apply an appropriate SCC - this example was tested with `privileged`. 
       For example:

       oc adm policy add-scc-to-user privileged -z default
    
    5. Create the image pull secret:

        oc apply -f image-pull.yaml

    6. Deploy the agents e.g. 

        oc apply -f source-agent.yaml dest-agent.yaml

To test, open a terminal into an agent pod and create a file e.g. /tmp/test.txt.  Then run a command like this:

    /opt/mqm/bin/fteCreateTransfer -sa SOURCE -sm AGENT.SOURCE -da DEST -dm AGENT.DEST -dd /tmp /tmp/test.txt
