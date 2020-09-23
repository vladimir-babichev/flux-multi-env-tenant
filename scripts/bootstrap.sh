#!/usr/bin/env bash

: ${1?"Usage: $0 <ENVIRONMENT>"}

REPO_GIT_INIT_PATHS="environment/$1"
REPO_URL=git@github.com:vladimir-babichev/flux-multi-env-tenant
REPO_BRANCH=master

helm repo add fluxcd https://charts.fluxcd.io

echo ">>> Installing Flux for ${REPO_URL} only watching the ${REPO_GIT_INIT_PATHS} directory"
kubectl create ns flux || true
helm upgrade -i flux fluxcd/flux --wait \
--set git.url=${REPO_URL} \
--set git.branch=${REPO_BRANCH} \
--set git.path=${REPO_GIT_INIT_PATHS} \
--set git.pollInterval=1m \
--set manifestGeneration=true \
--set registry.pollInterval=1m \
--set sync.state=secret \
--set syncGarbageCollection.enabled=true \
--namespace flux-system

echo ">>> Installing Helm Operator"
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml
helm upgrade -i helm-operator fluxcd/helm-operator --wait \
--namespace flux-system \
--set git.ssh.secretName=flux-git-deploy \
--set helm.versions=v3

echo ">>> Updating Flux key"
export NAMESPACE=flux-system
kubectl delete secret flux-git-deploy -n $NAMESPACE
kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/flux-system -n $NAMESPACE
kubectl rollout restart deploy flux -n $NAMESPACE

echo ">>> Cluster bootstrap done!"
