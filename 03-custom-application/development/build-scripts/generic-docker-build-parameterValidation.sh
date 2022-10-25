#!/bin/bash

#
# Wrapper script to validate build parameters for all service build scripts
#


set -o errexit # fail on error
#set -x # log each command before executing

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"
INTERNAL_SCRIPT_DIR="$SCRIPT_DIR/../_local-dev/scripts/internal"
source $INTERNAL_SCRIPT_DIR/k8s-env.sh
source $INTERNAL_SCRIPT_DIR/../define-colors.sh


function show_help(){
    echo "help"
}

###
### init constants
###
REGISTRY=
VERSION=
DOCKER_TAG_PATH_PREFIX=
VERBOSE=0
DEPLOY=true
MODE=
BASE_IMAGE=localhost:5000/service-base-image:latest

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
                if [[ "${MODE}" != local && "${MODE}" != dev && "${MODE}" != release ]]; then # replace bash glob expression "@(local|dev|release)" in favour for the mac users
                    echo "invalid mode --MODE $MODE, allowed values are 'local' 'dev' 'release'"
                    exit
                else
                    echo "MODE=$MODE"
                fi
                shift
            fi
            ;;
        -r|--registry)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                REGISTRY=$2
                shift
            else
                die 'ERROR: "--file" requires a non-empty option argument.'
            fi
            ;;
        -v|--version)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                VERSION=$2
                shift
            else
                die 'ERROR: "--file" requires a non-empty option argument.'
            fi
            ;;
        -b|--baseImage)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                BASE_IMAGE=$2
                shift
            fi
            ;;
        -dtpp|--dockerTagPathPrefix)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                DOCKER_TAG_PATH_PREFIX=$2
                shift
            else
                die 'ERROR: "--file" requires a non-empty option argument.'
            fi
            ;;
        --disable-deploy)       # Takes an option argument; ensure it has been specified.
            DEPLOY=false
            ;;
        --verbose)
            VERBOSE=$((VERBOSE + 1))  # Each -v adds 1 to verbosity.
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



###
### validate parameters
###

# selecting mode
if [ -z "$MODE" ]
then
      MODE="local"
fi
echo "MODE=$MODE"

# selecting registry
if [ -z "$REGISTRY" ]
then
      echo "Using local docker container registry"
      REGISTRY="$DOCKER_REGISTRY_HOST:$DOCKER_REGISTRY_PORT"
fi
echo "REGISTRY=$REGISTRY"

# selecting version
if [ -z "$VERSION" ]
then
      VERSION="latest"
fi
echo "VERSION=$VERSION"


# selecting DOCKER_TAG_PATH_PREFIX
if [ -z "$DOCKER_TAG_PATH_PREFIX" ]
then
      DOCKER_TAG_PATH_PREFIX="/"
else

    [[ $DOCKER_TAG_PATH_PREFIX = /* ]] || DOCKER_TAG_PATH_PREFIX="/$DOCKER_TAG_PATH_PREFIX"
    [[ $DOCKER_TAG_PATH_PREFIX = */ ]] || DOCKER_TAG_PATH_PREFIX="$DOCKER_TAG_PATH_PREFIX/"

fi
echo "DOCKER_TAG_PATH_PREFIX=$DOCKER_TAG_PATH_PREFIX"

echo "BASE_IMAGE=$BASE_IMAGE"