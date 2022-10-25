#!/bin/bash
#set -x
set -o errexit # fail on error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"
INTERNAL_SCRIPT_DIR="$SCRIPT_DIR/../_local-dev/scripts/internal"
source $SCRIPT_DIR/generic-service-deployment-validator.sh

TIMEOUT="40s"
DEPLOYMENT_NAME="greeting"
VERSION_REST_PATH="/greeting/v1/version"

echo -e "${GREEN} Deployment $DEPLOYMENT_NAME - Testing ${NO_COLOR}"

kubectl wait pod -n local --for=condition=Ready --selector=app=greeting --timeout="$TIMEOUT"
PODS_READY=$?

kubectl -n local wait deployment $DEPLOYMENT_NAME --for condition=Available=True --timeout="$TIMEOUT"
DEPLOYMENT_READY=$?

# exit code is zero if successfull
if [[ $DEPLOYMENT_READY -ne 0 && $PODS_READY -ne 0 ]]; then

  kubectl -n local get pods -l "app=blueprint-greeting"
  kubectl -n local get svc blueprint-greeting -o wide

  die "Deployment does not became ready in time ( $TIMEOUT )"
fi


# test version endpoint
URL="${API_HOST[$STAGE_ID]}${VERSION_REST_PATH}"

checkVersion "$URL" "$VERSION"

echo -e "${GREEN} Deployment $DEPLOYMENT_NAME - finished.${NO_COLOR}"