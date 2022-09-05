# MQ MFT in CP4I
## Introduction

MQ MFT is not part of the standard IBM CP4I image for MQ. However, you can build your own container and MQ is supported if you do that.  This repository is an example of how this could be done.  It is not supported by IBM and is for demonstration purposes only.

In this example, there are two agents - source and destination.  Each has its own queue manager, and there is one command QM and one coordination QM.  All four are deployed independently as standalone QMs via CP4I.  This means that they need TCP connections and channels between them.
