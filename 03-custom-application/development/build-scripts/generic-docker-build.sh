#!/bin/bash
#set -x
set -o errexit # fail on error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"

###
### defaults
###

RUN_TESTS=true

###
### parse parameters
###

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage options.
            exit
            ;;
        -m|--mode)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                MODE=$2
                 if [[ "${MODE}" != debug && "${MODE}" != runtime && "${MODE}" != release ]]; then # replace bash glob expression "@(local|dev|release)" in favour for the mac users
                    echo "invalid mode --MODE $MODE, allowed values are 'debug' 'runtime' 'release'"
                    exit
                 else
                    echo "MODE=$MODE"
                fi
                shift
            fi
            ;;
        -v|--version)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                VERSION=$2
                shift
            else
                echo 'ERROR: "-v|--version" requires a non-empty option argument.'
            fi
            ;;
        -c|--cacheTag)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                CACHE_TAG=$2
                shift
            fi
            ;;
        -t|--docker-image-name)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                DOCKER_IMAGE_NAME=$2
                shift
            else
                echo 'ERROR: "-t|--docker-image-name" requires a non-empty option argument.'
                exit 1
            fi
            ;;
        -n|--base-image-name)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                BASE_IMAGE_NAME=$2
                shift
            fi
            ;;
        -p|--component-path)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                COMPONENT_PATH=$2
                shift
            else
                echo 'ERROR: "-p|--component-path" requires a non-empty option argument.'
                exit 1
            fi
            ;;
        --disable-test)       # Takes an option argument; ensure it has been specified.
            RUN_TESTS=false
            ;;
        --verbose)
            VERBOSE=$((VERBOSE + 1))  # Each -v adds 1 to verbosity.
            ;;
        -f|--dockerfile)       # Takes an option argument; ensure it has been specified.
                DOCKER_FILE=$2
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done








SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
BUILD_REPORTS_DIR="$SCRIPT_DIR/../build-reports"
SERVICE_BUILD_REPORT_DIR="$BUILD_REPORTS_DIR/$COMPONENT_PATH"
mkdir -p "$SERVICE_BUILD_REPORT_DIR"

DOCKER_ROOT_BUILD_DIR=$( cd "$SCRIPT_DIR/../"; pwd )

## activate docker buildkit
export DOCKER_BUILDKIT=1


function validateParams(){
  # if DOCKER_FILE Param is not set assume service build
  if [ -z ${DOCKER_FILE+x} ]; then
    DOCKER_FILE=$DOCKER_ROOT_BUILD_DIR/docker/service/Dockerfile
    echo "Using dockerfile $DOCKER_FILE"
  fi
  if [ ! -f "$DOCKER_FILE" ]; then
      echo "expecting docker file $DOCKER_FILE"
      exit 1;
  fi

  if [ -z ${COMPONENT_PATH+x} ]; then
    echo "-p COMPONENT_PATH is unset";
    exit 1;
  fi

  if [ -z ${VERSION+x} ]; then
    echo "-v Version is not set, using latest";
    VERSION="latest"
  fi

  DOCKER_TAG="$DOCKER_IMAGE_NAME:$VERSION"
  DOCKER_LATEST_TAG="$DOCKER_IMAGE_NAME:latest"

  if [ -z "$CACHE_TAG" ]; then
    CACHE_TAG=$DOCKER_LATEST_TAG
  fi

  if [ -z ${BASE_IMAGE_NAME+x} ]; then
    echo "BASE_IMAGE_NAME is not set, using localhost:5000/service-base-image:latest"
    BASE_IMAGE_NAME="$DOCKER_REGISTRY/development/service-base-image:latest"
  fi
}



function runTests() {


  DOCKER_BUILDKIT=1 docker build \
    -t "$DOCKER_TAG" \
    -t "$DOCKER_LATEST_TAG" \
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
      echo "Some unit tests failed"
      exit "$unit_test_exit_status"
  fi

}


function buildContainer() {
  validateParams
  if [ "$RUN_TESTS" = true ] ; then
      echo 'Execute tests ...'
      runTests
  fi
  echo "docker build image $DOCKER_TAG  latest: $DOCKER_LATEST_TAG"
#  DOCKER_BUILDKIT=1 docker build -t $DOCKER_TAG -t $DOCKER_LATEST_TAG -f $DOCKER_FILE --cache-from=$CACHE_TAG --build-arg build_mode=$MODE --build-arg BASE_IMAGE=$BASE_IMAGE_NAME --build-arg COMPONENT_PATH=$COMPONENT_PATH  --build-arg SERVICE_VERSION=$VERSION $DOCKER_ROOT_BUILD_DIR --no-cache
  DOCKER_BUILDKIT=1 docker build \
    -t "$DOCKER_TAG" \
    -t "$DOCKER_LATEST_TAG" \
    -f "$DOCKER_FILE" \
    --cache-from="$CACHE_TAG" \
    --build-arg build_mode="$MODE" \
    --build-arg BASE_IMAGE="$BASE_IMAGE_NAME" \
    --build-arg COMPONENT_PATH="$COMPONENT_PATH"  \
    --build-arg SERVICE_VERSION="$VERSION" \
    "$DOCKER_ROOT_BUILD_DIR"

  echo "docker build sucessful, start pushing image ..."
  DOCKER_BUILDKIT=1 docker push -a "$DOCKER_IMAGE_NAME" --quiet
}
START=$(date +%s)
buildContainer
END=$(date +%s)
DIFF=$(( $END - $START ))

echo -e "${BLUE}Full docker build took $DIFF seconds ${NO_COLOR} "