#!/usr/bin/env bash
set -euo pipefail

# make sure you did:
# docker login ${REGISTRY}
# that probably needs an access key

if [ $# -eq 0 ]; then
  TARGET=dev
else
  TARGET=$1
fi

IMAGENAME=nano
VERSION=$(yq ".${TARGET}" version.yaml)
echo "Building verion ${VERSION}"

docker build -t ${IMAGENAME}:${VERSION} .
docker tag nano:${VERSION} nano:latest

IMAGE_URL=${REGISTRY}/${PROJECTDIR}/${IMAGENAME}:${VERSION}

docker tag nano:${VERSION} ${IMAGE_URL}
docker push ${IMAGE_URL}

echo "$0 done"
