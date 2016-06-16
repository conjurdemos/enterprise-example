#!/bin/bash -e

docker build -t ee-admin -f Dockerfile.admin .
docker build -t ee-populate -f Dockerfile.populate .
