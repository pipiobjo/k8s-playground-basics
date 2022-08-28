#!/bin/bash

#set -x
set -o errexit # fail on error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"
source "$SCRIPT_DIR/define-colors.sh"

################
# CONSTANTS
################

# possible values local dev release
# check dockerfile for usage of mode
#MODE="local"
MODE="dev"

SERVICE_PATH="$SCRIPT_DIR/../service/greeting/"
K8S_PLAYGROUND_DIR="../../../../k8s-playground"
SERVICE_NAME="service-greeting"
# Import k8s env variables
source "$K8S_PLAYGROUND_DIR/kind/shell-based-setup/k8s/scripts/k8s-env.sh"

DOCKER_FILE="$SCRIPT_DIR/../docker/service/Dockerfile"
DOCKER_ROOT_BUILD_DIR="$SCRIPT_DIR/../"
COMPONENT_PATH="./service/greeting"

BUILD_REPORTS_DIR="$SCRIPT_DIR/../build-reports"
SERVICE_BUILD_REPORT_DIR="$BUILD_REPORTS_DIR/$COMPONENT_PATH"

DOCKER_REGISTRY="$DOCKER_REGISTRY_HOST:$DOCKER_REGISTRY_PORT"

BASE_IMAGE_NAME="$DOCKER_REGISTRY/development/service-base-image:latest"


VERSION=$(date +%Y%m%d%H%M%S)
DOCKER_REMOTE_IMAGE="$DOCKER_REGISTRY/development/$SERVICE_NAME"
DOCKER_REMOTE_IMAGE_VERSION_TAG="$DOCKER_REMOTE_IMAGE:$VERSION"
DOCKER_REMOTE_IMAGE_LATEST_TAG="$DOCKER_REMOTE_IMAGE:latest"
CACHE_TAG=$DOCKER_REMOTE_IMAGE_LATEST_TAG

echo -e "${GREEN}DOCKER_REMOTE_IMAGE: $DOCKER_REMOTE_IMAGE ${NO_COLOR} "
echo -e "${GREEN}DOCKER_REMOTE_IMAGE_VERSION_TAG: $DOCKER_REMOTE_IMAGE_VERSION_TAG ${NO_COLOR} "

################################
# DOCKER BUILD - Execute Tests
################################

START=$(date +%s)

DOCKER_BUILDKIT=1 docker build \
  -t "$DOCKER_REMOTE_IMAGE_VERSION_TAG" \
  -t "$DOCKER_REMOTE_IMAGE_LATEST_TAG" \
  -f "$DOCKER_FILE" \
  --cache-from="$CACHE_TAG" \
  --build-arg build_mode="$MODE" \
  --build-arg BASE_IMAGE="$BASE_IMAGE_NAME" \
  --build-arg COMPONENT_PATH="$COMPONENT_PATH" \
  --build-arg SERVICE_VERSION="$VERSION" \
  --target=test-results \
  --output type=local,dest="$SERVICE_BUILD_REPORT_DIR" \
  "$DOCKER_ROOT_BUILD_DIR"

unit_test_exit_status=$(cat "$SERVICE_BUILD_REPORT_DIR/EXIT_STATUS_FILE")
if [ "$unit_test_exit_status" -ne 0 ]; then
    echo -e "${RED}Some unit tests failed${NO_COLOR}"
    exit "$unit_test_exit_status"
fi

############################################
# DOCKER BUILD - Build Runtime Container
############################################


echo -e "${GREEN}docker build image $DOCKER_TAG  latest: $DOCKER_LATEST_TAG${NO_COLOR}"
DOCKER_BUILDKIT=1 docker build \
  -t "$DOCKER_REMOTE_IMAGE_VERSION_TAG" \
  -t "$DOCKER_REMOTE_IMAGE_LATEST_TAG" \
  -f "$DOCKER_FILE" \
  --cache-from="$CACHE_TAG" \
  --build-arg build_mode="$MODE" \
  --build-arg BASE_IMAGE="$BASE_IMAGE_NAME" \
  --build-arg COMPONENT_PATH="$COMPONENT_PATH"  \
  --build-arg SERVICE_VERSION="$VERSION" \
  "$DOCKER_ROOT_BUILD_DIR"


################
# DOCKER PUSH
################

echo -e "${GREEN}docker build sucessful, start pushing image ...${NO_COLOR}"
DOCKER_BUILDKIT=1 docker push -a "$DOCKER_REMOTE_IMAGE" --quiet



END=$(date +%s)
DIFF=$(( $END - $START ))
echo -e "${BLUE}Full docker build took $DIFF seconds ${NO_COLOR} "
