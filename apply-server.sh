#!/bin/bash
if [ $# -eq 1 ]
then
  echo "Going to work with the Valheim server $1";
  kubectl create ns valheim
  kubectl apply -f $1/valheim-pvc.yaml -n valheim
  kubectl apply -f valheim-player-lists-cm.yaml -n valheim
  echo "Hope you remembered to update the passwords in the secrets file only locally!"
  kubectl apply -f valheim-secrets.yaml -n valheim
  kubectl apply -f $1/valheim-service.yaml -n valheim
  kubectl apply -f $1/valheim-deployment.yaml -n valheim
  # TODO: Consider using a stateful set just to get a cleaner pod name? Only ever 0 or 1 instances ...
else
  echo "Didn't get exactly one arg, got $# ! $*"
  echo "Valid server names are: valheim1, valheim2"
fi
