#!/bin/bash
if [ $# -eq 1 ]
then
  echo "Going to delete the Valheim server $1";
  kubectl delete -f $1/valheim-pvc.yaml
  kubectl delete -f valheim-player-lists-cm.yaml
  kubectl delete -f valheim-secrets.yaml
  kubectl delete -f $1/valheim-service.yaml
  kubectl delete -f $1/valheim-deployment.yaml
else
  echo "Didn't get exactly one arg, got $# ! $*"
  echo "Valid server names are: valheim1"
fi
