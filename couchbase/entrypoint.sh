#!/bin/bash
set -x
set -m

/entrypoint.sh couchbase-server &

sleep 15

# Default values
if [ ! -z $ADMIN_LOGIN ]
then
  ADMIN_LOGIN="Administrator"
fi

if [ ! -z $ADMIN_PWD ]
then
  ADMIN_PWD="password"
fi

if [ ! -z $RAM_SIZE ]
then
  ADMIN_PWD="300"
fi

if [ ! -z $NODE_TYPE ]
then
  NODE_TYPE="MASTER"
fi
# End default values

# Creation of the first node
couchbase-cli cluster-init -c localhost:8091 --cluster-username=$ADMIN_LOGIN --cluster-password=$ADMIN_PWD --cluster-port=8091 --services=data,index,query,fts --cluster-ramsize=$RAM_SIZE --cluster-index-ramsize=$RAM_SIZE --cluster-fts-ramsize=$RAM_SIZE --index-storage-setting=memopt

# Load travel-sample bucket
#curl -v -u Administrator:password -X POST http://127.0.0.1:8091/sampleBuckets/install -d '["travel-sample"]'


#wget https://ressources.data.sncf.com/explore/dataset/regularite-mensuelle-tgv/download/?format=json\&timezone=Europe\/Berlin -O jdd.json

# Additionnal actions for a cluster
echo "Type: $NODE_TYPE"

if [ "$NODE_TYPE" = "WORKER" ]; then
  echo "Sleeping ..."
  sleep 15

  #IP=`hostname -s`
  IP=`hostname -I | cut -d ' ' -f1`
  echo "IP: " $IP

  echo "Auto Rebalance: $AUTO_REBALANCE"
  if [ "$AUTO_REBALANCE" = "true" ]; then
    couchbase-cli rebalance --cluster=$COUCHBASE_MASTER:8091 --user=$ADMIN_LOGIN --password=$ADMIN_PWD --server-add=$IP --server-add-username=$ADMIN_LOGIN --server-add-password=$ADMIN_PWD
  else
    couchbase-cli server-add --cluster=$COUCHBASE_MASTER:8091 --user=$ADMIN_LOGIN --password=$ADMIN_PWD --server-add=$IP --server-add-username=$ADMIN_LOGIN --server-add-password=$ADMIN_PWD
  fi;
fi;

fg 1