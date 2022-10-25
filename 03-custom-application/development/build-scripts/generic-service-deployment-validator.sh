#!/bin/bash

#
# Wrapper script to validate build parameters
#


set -o errexit # fail on error
#set -x # log each command before executing

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/"

source "$SCRIPT_DIR/../../define-colors.sh"


function show_help(){
    echo "help"
}

function die () {
  local message=$1
  [ -z "$message" ] && message="Died"
  echo -e "${RED}ERROR:  $message ( at ${BASH_SOURCE[1]}:${FUNCNAME[1]} line ${BASH_LINENO[0]} ) ${NO_COLOR} " >&2

  exit 1
}

###
### init constants
###
VERSION=
STAGE_ID=



###
### parse parameters
###

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage options.
            exit
            ;;

        --version)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                VERSION=$2
                shift
            fi
            ;;

        --stageId)       # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                STAGE_ID=$2
                shift
            fi
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
if [ -z "$STAGE_ID" ]; then
  die '"--stageId" requires a non-empty option argument.'
else
  if [[ "${STAGE_ID}" != local && "${STAGE_ID}" != dev && "${STAGE_ID}" != abnahme && "${STAGE_ID}" != prelive && "${STAGE_ID}" != prod ]]; then # replace bash glob expression "@(local|dev|abnahme|prelive|prod)" in favour for the mac users
      die "invalid mode --stageId $STAGE_ID, allowed values are 'local' 'dev' 'abnahme' 'prelive' 'prod'"
  fi
fi


# selecting version
if [ -z "$VERSION" ]; then
  die '"--version" requires a non-empty option argument.'
fi

if [ "$STAGE_ID" == "local" ]; then
  INTERNAL_SCRIPT_DIR="$SCRIPT_DIR/../_local-dev/scripts/internal"
  source $INTERNAL_SCRIPT_DIR/k8s-env.sh
fi

declare -A API_HOST

API_HOST[local]="http://localhost:${K8S_HTTP_PORT}/local"
API_HOST[dev]="http://localhost:${K8S_HTTP_PORT}/dev"
API_HOST[prelive]="http://localhost:${K8S_HTTP_PORT}/prelive"
API_HOST[prod]="http://localhost:${K8S_HTTP_PORT}/prod"




##################
## decleare generic functions
###################

function checkVersionHTTPCall (){
  VERSION_URL=$1
  EXPECTED_VERSION=$2

  VERSION_RESPONSE=$(curl -si -w "\n%{size_header},%{size_download},%{http_code}" "${VERSION_URL}")
  VERSION_RESPONSE_METADATA_lastLine=$(echo "$VERSION_RESPONSE" | tail -n1)

  VERSION_RESPONSE_HEADER_SIZE=$(echo $VERSION_RESPONSE_METADATA_lastLine | cut -d ',' -f1 )
  VERSION_RESPONSE_BODY_SIZE=$(echo $VERSION_RESPONSE_METADATA_lastLine | cut -d ',' -f2 )
  VERSION_RESPONSE_HTTP_STATUS_CODE=$(echo $VERSION_RESPONSE_METADATA_lastLine | cut -d ',' -f3 )

  VERSION_RESPONSE_HEADERS="${VERSION_RESPONSE:0:${VERSION_RESPONSE_HEADER_SIZE}}"
  VERSION_RESPONSE_BODY="${VERSION_RESPONSE:${VERSION_RESPONSE_HEADER_SIZE}:${VERSION_RESPONSE_BODY_SIZE}}"

  if [[ $VERSION_RESPONSE_HTTP_STATUS_CODE -ne 200 ]]; then
    echo -e "${RED}WARN: Calling version endpoint failed $URL ${NO_COLOR} "
    return 1
  fi

  DEPLOYED_VERSION=$(echo $VERSION_RESPONSE_BODY | jq '.version')
  if [[ ! "$DEPLOYED_VERSION" == "\"$EXPECTED_VERSION\"" ]];then
    echo -e "${DARK_GRAY}WARN: Starting new pods failed, expecting new version \"$EXPECTED_VERSION\" but got $DEPLOYED_VERSION from $URL ${NO_COLOR} "
    return 1
  fi
  echo -e "${BLUE} Deployment $DEPLOYMENT_NAME - Found version \"$EXPECTED_VERSION\" ${NO_COLOR}"
  return 0

}


function checkVersion (){
  VERSION_URL=$1
  EXPECTED_VERSION=$2
  RESULT=0

  # try calling version endpoint 5 times with idle time of 5 seconds
  n=1
  until [ "$n" -ge 5 ]
  do
     echo "Checking version attempt $n of 5"
     checkVersionHTTPCall "$VERSION_URL" "$EXPECTED_VERSION" && break
     RESULT=$?
     n=$((n+1))
     sleep 5
  done
  return $RESULT
}
