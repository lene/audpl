#!/bin/bash
set -xv

### Definitions
HOSTNAME=${1:-"ec2-54-246-221-140"}
REGION=eu-west-1
KEY=ireland.pem
USER=ubuntu

SWAPSIZE={2:-4096}

TARGET_HOST="${USER}@${HOSTNAME}.${REGION}.compute.amazonaws.com"
SSH_ARGS="-i ${HOME}/.ssh/${KEY}"

### Actions

### Local
scp ${SSH_ARGS} ${HOME}/.bashrc ${TARGET_HOST}:
scp ${SSH_ARGS} scripts/ec2_bootstrap_remote.sh ${TARGET_HOST}:

### Remote
ssh ${SSH_ARGS} ${TARGET_HOST} ./ec2_bootstrap_remote.sh ${SWAPSIZE}

### Local
scp ${SSH_ARGS} ${HOME}/workspace/style-scout/ebay_auth.json ${TARGET_HOST}:style-scout

### Drop into interactive shell
ssh ${SSH_ARGS} ${TARGET_HOST}
