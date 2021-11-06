#!/usr/bin/env bash
# 1. Install
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update

# helm search repo chaos-mesh
kubectl create ns chaos-testing

helm upgrade -i chaos-mesh chaos-mesh/chaos-mesh -n chaos-testing \
    --version 2.0.3 \
    --set controllerManager.enableFilterNamespace=true 

kubectl get crds
kubectl get all -n chaos-testing
kubectl get ns -o jsonpath='{.items[?(@.metadata.annotations.chaos-mesh\.org/inject=="enabled")].metadata.name}'

# path chaos-dashboard to make nodeport
kubectl patch service chaos-dashboard -n chaos-mesh \
--type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31111}]'