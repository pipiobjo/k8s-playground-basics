#!/bin/bash

set -o errexit
#set -x

#### LOAD CONSTANTS
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/../define-colors.sh


echo -e "${GREEN} create namespaces ${NO_COLOR}"

Namespace="local"
kubectl get namespace | grep -q "^$Namespace " || kubectl create namespace $Namespace

Namespace="dev"
kubectl get namespace | grep -q "^$Namespace " || kubectl create namespace $Namespace

Namespace="prelive"
kubectl get namespace | grep -q "^$Namespace " || kubectl create namespace $Namespace

Namespace="prod"
kubectl get namespace | grep -q "^$Namespace " || kubectl create namespace $Namespace
