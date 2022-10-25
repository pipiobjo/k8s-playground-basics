#!/bin/bash

#set -x
set -o errexit # fail on error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"
source "$SCRIPT_DIR/../..//define-colors.sh"

K8S_PLAYGROUND_DIR="$SCRIPT_DIR/../../../../../k8s-playground"
###############
# K8S (KIND) DEFAULTS
###############
source "$K8S_PLAYGROUND_DIR/kind/shell-based-setup/k8s/scripts/k8s-env.sh"
DOCKER_REGISTRY="$DOCKER_REGISTRY_HOST:$DOCKER_REGISTRY_PORT"

################
# CONSTANTS
################
SERVICE_PATH="service/greeting/"
SERVICE_NAME="greeting"

DOCKER_FILE="$SCRIPT_DIR/../docker/service/Dockerfile"
DOCKER_ROOT_BUILD_DIR="$SCRIPT_DIR/../"
COMPONENT_PATH="./service/greeting"
BUILD_REPORTS_DIR="$SCRIPT_DIR/../build-reports"
SERVICE_BUILD_REPORT_DIR="$BUILD_REPORTS_DIR/$COMPONENT_PATH"

################################
# CONFIGURATION_PARAMETERS
################################



# possible values local dev release
# check dockerfile for usage of mode
MODE="debug"
#MODE="runtime"
#MODE="release"



################
# PARAMETERS
################


BASE_IMAGE="$DOCKER_REGISTRY/development/service-base-image:latest"


if [ -n "$1" ]; then
  VERSION=$1
else
  VERSION=$(date +%Y%m%d%H%M%S)
fi
echo "generating docker with version=$VERSION"

DOCKER_REMOTE_IMAGE="$DOCKER_REGISTRY/development/$SERVICE_NAME"
#DOCKER_REMOTE_IMAGE_VERSION_TAG="$DOCKER_REMOTE_IMAGE:$VERSION"
DOCKER_REMOTE_IMAGE_LATEST_TAG="$DOCKER_REMOTE_IMAGE:latest"
CACHE_TAG=$DOCKER_REMOTE_IMAGE_LATEST_TAG

echo -e "${GREEN}DOCKER_REMOTE_IMAGE: $DOCKER_REMOTE_IMAGE ${NO_COLOR} "

################################
# DOCKER BUILD - Execute Tests
################################

START=$(date +%s)

###
### build container
###
echo -e "${GREEN} build oci image - $SERVICE_NAME  ${NO_COLOR}"
REMOTE_DOCKER_TAG="${DOCKER_REGISTRY}${DOCKER_TAG_PATH_PREFIX}/${SERVICE_NAME}"
$SCRIPT_DIR/./generic-docker-build.sh \
  -p $SERVICE_PATH \
  -t $DOCKER_REMOTE_IMAGE \
  -v "$VERSION" \
  -m "$MODE" \
  -n "$BASE_IMAGE" \
  -c "$CACHE_TAG"


#########################
# BUILD & DEPLOY K8S MANIFESTS
#########################

$SCRIPT_DIR/./generic-k8s-build.sh -p $SERVICE_PATH -t "$SERVICE_NAME" -d "$DOCKER_REMOTE_IMAGE:$VERSION" -m "local"


########################
# Validate Deployment
########################

#$SCRIPT_DIR/./validate-greeting.sh --stageId local --version "$VERSION"