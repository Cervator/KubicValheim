#!/bin/bash
if [ $# -eq 1 ]
then
  echo "Going to work with the Valheim server $1";
  kubectl apply -f $1/valheim-pvc.yaml
  kubectl apply -f valheim-player-lists-cm.yaml
  kubectl apply -f valheim-startup-script-cm.yaml
  echo "Hope you remembered to update the passwords in the secrets file only locally!"
  kubectl apply -f valheim-secrets.yaml
  kubectl apply -f $1/valheim-service.yaml
  kubectl apply -f $1/valheim-deployment.yaml
  # TODO: Consider using a stateful set just to get a cleaner pod name? Only ever 0 or 1 instances ...
else
  echo "Didn't get exactly one arg, got $# ! $*"
  echo "Valid server names are: valheim1"
fi
