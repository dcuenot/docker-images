#!/bin/bash
set -x
set -m

/entrypoint.sh couchbase-server &

sleep 15

# Default values
if [ -z "$ADMIN_LOGIN" ]
then
  ADMIN_LOGIN="Administrator"
fi

if [ -z "$ADMIN_PWD" ]
then
  ADMIN_PWD="password"
fi

if [ -z "$RAM_SIZE" ]
then
  RAM_SIZE="300"
fi

if [ -z "$BUCKET_NAME" ]
then
  BUCKET_NAME="bucket"
fi

if [ -z "$NODE_TYPE" ]
then
  NODE_TYPE="MASTER"
fi
# End default values

# First node creation
couchbase-cli cluster-init -c localhost:8091 --cluster-username=$ADMIN_LOGIN --cluster-password=$ADMIN_PWD --cluster-port=8091 --services=data,index,query,fts --cluster-ramsize=$RAM_SIZE --cluster-index-ramsize=$RAM_SIZE --cluster-fts-ramsize=$RAM_SIZE --index-storage-setting=memopt

# Bucket creation
couchbase-cli bucket-create -c localhost:8091 --bucket=$BUCKET_NAME --bucket-type=couchbase --bucket-ramsize=$RAM_SIZE --bucket-replica=1 --bucket-priority=high --wait -u $ADMIN_LOGIN -p $ADMIN_PWD  

# Add samples
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