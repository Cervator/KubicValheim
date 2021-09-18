#!/bin/bash
if [ $# -eq 1 ]
then
  echo "Going to delete the Valheim server $1";
  kubectl delete -f $1/valheim-deployment.yaml  -n valheim
  kubectl delete -f valheim-player-lists-cm.yaml -n valheim
  kubectl delete -f valheim-secrets.yaml -n valheim
  kubectl delete -f $1/valheim-service.yaml -n valheim
  kubectl delete -f $1/valheim-pvc.yaml -n valheim
else
  echo "Didn't get exactly one arg, got $# ! $*"
  echo "Valid server names are: valheim1, valheim2"
fi
