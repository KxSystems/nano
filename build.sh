#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
   echo "illegal number of parameters"
   echo "$0 nexus|gitlab"
   exit 1
fi

# Container Registry settings
# make sure you did, e.g.:
# docker login ${GITLABREGISTRY}
# that probably needs an access key
GITLABREGISTRY="registry.gitlab.com"
NEXUSREGISTRY="ext-dev-registry.kxi-dev.kx.com"

# Set the project directory of your container registry
GITLABPROJECTDIR="kxdev/benchmarking/nano"
NEXUSPROJECTDIR="benchmarking"
IMAGENAME=nano
VERSION=$(yq '.pub' version.yaml)

docker build -t ${IMAGENAME}:${VERSION} .

docker tag nano:${VERSION} nano:latest

if [ $1 == "gitlab" ]; then
  FULLNAME=${GITLABREGISTRY}/${GITLABPROJECTDIR}/${IMAGENAME}:${VERSION}
elif [ $1 == "nexus" ]; then
  FULLNAME=${NEXUSREGISTRY}/${NEXUSPROJECTDIR}/${IMAGENAME}:${VERSION}
else
  echo "Unknown repo $1"
  exit 2
fi

docker tag nano:${VERSION} ${FULLNAME}
docker push ${FULLNAME}

echo "$0 done"
