#!/usr/bin/env bash
# path chaos-dashboard to make nodeport
kubectl patch service chaos-dashboard -n chaos-mesh \
--type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31111}]'

#1. Install Example web-show application
TARGET_IP=$(kubectl get pod -n kube-system -o wide| grep kube-controller | head -n 1 | awk '{print $6}')
kubectl create configmap web-show-context --from-literal=target.ip=${TARGET_IP}

# https://github.com/chaos-mesh/web-show
kubectl apply -f https://github.com/chaos-mesh/web-show/blob/master/deploy/deployment.yaml
kubectl apply -f https://github.com/chaos-mesh/web-show/blob/master/deploy/service.yaml

kubectl get deployments,pods -l app='web-show'

#2. Apply network-delay Experiment
#https://github.com/chaos-mesh/web-show/blob/master/chaos/network-delay.yaml
kubectl apply -f network-delay-experiment.yaml
kubectl get NetworkChaos
kubectl describe networkchaos web-show-network-delay
#Pause an Experiment
kubectl annotate networkchaos web-show-network-delay experiment.chaos-mesh.org/pause=true
#Resume an Experiment
kubectl annotate networkchaos web-show-network-delay experiment.chaos-mesh.org/pause-

#Delete an Experiment
kubectl delete -f kubectl apply -f network-delay-experiment.yaml

#3. Apply Scheduled network-delay Experiment
kubectl apply -f scheduled-nw-delay.yaml
kubectl get Schedule
kubectl describe web-show-scheduled-network-delay
kubectl annotate schedule web-show-scheduled-network-delay experiment.chaos-mesh.org/pause=true
kubectl annotate schedule web-show-scheduled-network-delay experiment.chaos-mesh.org/pause-

kubectl delete -f cheduled-nw-delay.yaml

#4 Pod Removal Experiment
kubectl create namespace chaos-sandbox
kubectl apply -f nginx.yaml -n chaos-sandbox
kubectl apply -f pod-removal-experiment.yaml
kubectl get Schedule -n chaos-mesh
kubectl get -n chaos-sandbox po -w

#Pause an Experiment
kubectl annotate networkchaos pod-kill-example experiment.chaos-mesh.org/pause=true
#Resume an Experiment
kubectl annotate networkchaos pod-kill-example experiment.chaos-mesh.org/pause-