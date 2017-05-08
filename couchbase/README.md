# Couchbase Docker Image

This directory shows how to build a custom Couchbase Docker image that:

* Configures the Couchbase server with Index, Data, Query and Full Text Search service
* Creates a bucket with the all allocated ram size
* (TODO) Loads some data in the bucket (TODO)
* (TODO) Is possible to be clusterized

## Build the Image for DEV

```console
docker build -t dcuenot/couchbase .
```

## Run the Container

```console
docker run -d -p 8091-8093:8091-8093 -p 11210:11210 dcuenot/couchbase
```