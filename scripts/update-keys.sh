#!/usr/bin/env bash

set -o errexit

export NAMESPACE=flux-system
kubectl delete secret flux-git-deploy -n $NAMESPACE
kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/flux-system -n $NAMESPACE
kubectl rollout restart deploy flux -n $NAMESPACE

export NAMESPACE=metrics-app
kubectl delete secret flux-git-deploy -n $NAMESPACE
kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/metrics_app_key -n $NAMESPACE
kubectl rollout restart deploy flux -n $NAMESPACE

export NAMESPACE=slo-app
kubectl delete secret flux-git-deploy -n $NAMESPACE
kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/slo_app_key -n $NAMESPACE
kubectl rollout restart deploy flux -n $NAMESPACE

export NAMESPACE=prometheus-operator
kubectl delete secret flux-git-deploy -n $NAMESPACE
kubectl create secret generic flux-git-deploy --from-file=identity=$HOME/.ssh/prometheus_operator_key -n $NAMESPACE
kubectl rollout restart deploy flux -n $NAMESPACE
