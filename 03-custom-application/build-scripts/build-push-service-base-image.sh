#!/bin/bash
#set -x
set -o errexit # fail on error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"
source "$SCRIPT_DIR/define-colors.sh"

################
# CONSTANTS
################

K8S_PLAYGROUND_DIR="$SCRIPT_DIR/../../../../k8s-playground"
SERVICE_NAME="service-base-image"
DOCKER_FILE="$SCRIPT_DIR/../docker/service-base/Dockerfile"
DOCKER_ROOT_BUILD_DIR="$SCRIPT_DIR/../docker/service-base"

################
# DOCKER BUILD
################
START=$(date +%s)

# Import k8s env variables
source "$K8S_PLAYGROUND_DIR/kind/shell-based-setup/k8s/scripts/k8s-env.sh"

DOCKER_REGISTRY="$DOCKER_REGISTRY_HOST:$DOCKER_REGISTRY_PORT"
DOCKER_REMOTE_IMAGE="$DOCKER_REGISTRY/development/$SERVICE_NAME"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

DOCKER_REMOTE_IMAGE_VERSION_TAG="$DOCKER_REMOTE_IMAGE:$TIMESTAMP"
DOCKER_REMOTE_IMAGE_LATEST_TAG="$DOCKER_REMOTE_IMAGE:latest"
CACHE_TAG=$DOCKER_REMOTE_IMAGE_LATEST_TAG



DOCKER_BUILDKIT=1 docker build \
  -t "$DOCKER_REMOTE_IMAGE_VERSION_TAG" \
  -t "$DOCKER_REMOTE_IMAGE_LATEST_TAG" \
  -f "$DOCKER_FILE" \
  --cache-from="$CACHE_TAG" \
  "$DOCKER_ROOT_BUILD_DIR"



################
# DOCKER PUSH
################

echo -e "${GREEN}docker build sucessful, start pushing image ...${NO_COLOR}"
DOCKER_BUILDKIT=1 docker push -a "$DOCKER_REMOTE_IMAGE" --quiet

END=$(date +%s)
DIFF=$(( $END - $START ))
echo -e "${GREEN}Full docker build took $DIFF seconds ${NO_COLOR} "