#!/bin/bash

# Read Input-Parameters
while getopts p:t:d:m: flag
do
    case "${flag}" in
        p) COMPONENT_PATH=${OPTARG};;
        d) DEPLOY=${OPTARG};; # localhost:5000/blueprint-greeting:latest
        t) DOCKER_IMAGE_NAME=${OPTARG};;
        m) MODE=${OPTARG};;
    esac
done

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
BUILD_REPORTS_DIR="$SCRIPT_DIR/../build-reports"
SERVICE_BUILD_REPORT_DIR="$BUILD_REPORTS_DIR/$COMPONENT_PATH/k8s"
mkdir -p $SERVICE_BUILD_REPORT_DIR


# kustomize does not allow path vars as arguments 
# so we have to switch to all directories
# https://github.com/kubernetes-sigs/kustomize/issues/2803
OLD_DIR=$(pwd)

K8S_BASE_DIR="$SCRIPT_DIR/../$COMPONENT_PATH/k8s"

echo "updating kustomize image from $DOCKER_IMAGE_NAME to $DEPLOY"

# local
ENV_DIR="$K8S_BASE_DIR/local"
echo "building k8s manifests for local - $ENV_DIR"
cd $ENV_DIR && kustomize edit set image $DOCKER_IMAGE_NAME=$DEPLOY
kustomize build "$ENV_DIR" > "$SERVICE_BUILD_REPORT_DIR/k8s-local.yaml"
cd $ENV_DIR && kustomize edit set image $DOCKER_IMAGE_NAME=service-greeting:latest

if [ "$MODE" == "local" ] ; then
    k8sctx="kind-k8s-playground" # hardcoded unsure if we want do depend on k8s-env.sh here
    kubectl config use-context $k8sctx
    kubectl apply -f "$SERVICE_BUILD_REPORT_DIR/k8s-local.yaml"
fi


# dev
ENV_DIR="$K8S_BASE_DIR/dev"
echo "building k8s manifests for dev - $ENV_DIR"
cd $ENV_DIR && kustomize edit set image $DOCKER_IMAGE_NAME=$DEPLOY
kustomize build "$ENV_DIR" > "$SERVICE_BUILD_REPORT_DIR/k8s-dev.yaml"

if [ "$MODE" == "dev" ] ; then
    k8sctx="kind-k8s-playground" # hardcoded unsure if we want do depend on k8s-env.sh here
    kubectl config use-context $k8sctx
    kubectl apply -f "$SERVICE_BUILD_REPORT_DIR/k8s-dev.yaml"
fi



# prelive
ENV_DIR="$K8S_BASE_DIR/prelive"
echo "building k8s manifests for prelive - $ENV_DIR"
cd $ENV_DIR && kustomize edit set image $DOCKER_IMAGE_NAME=$DEPLOY
kustomize build "$ENV_DIR" > "$SERVICE_BUILD_REPORT_DIR/k8s-prelive.yaml"

if [ "$MODE" == "prelive" ] ; then
    k8sctx="kind-k8s-playground" # hardcoded unsure if we want do depend on k8s-env.sh here
    kubectl config use-context $k8sctx
    kubectl apply -f "$SERVICE_BUILD_REPORT_DIR/k8s-prelive.yaml"
fi



# prod
ENV_DIR="$K8S_BASE_DIR/prod"
echo "building k8s manifests for prod - $ENV_DIR"
cd $ENV_DIR && kustomize edit set image $DOCKER_IMAGE_NAME=$DEPLOY
kustomize build "$ENV_DIR" > "$SERVICE_BUILD_REPORT_DIR/k8s-prod.yaml"

if [ "$MODE" == "prod" ] ; then
    k8sctx="kind-k8s-playground" # hardcoded unsure if we want do depend on k8s-env.sh here
    kubectl config use-context $k8sctx
    kubectl apply -f "$SERVICE_BUILD_REPORT_DIR/k8s-prod.yaml"
fi


cd $OLD_DIR