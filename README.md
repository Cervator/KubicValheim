## Kubic Valheim

A setup for making [Valheim](https://www.valheimgame.com/) work in a Kubernetes cluster, with extra conveniences around config files (stored in ConfigMaps)

An eventual goal is to include automatic server hibernation to keep hosting costs down while using [ChatOps](https://docs.stackstorm.com/chatops/chatops.html) for server maintenance tasks (for instance: asking a bot on Discord to please start up server `x` when somebody wants to play there)

Uses the [Docker image](https://hub.docker.com/r/mbround18/valheim) from https://github.com/mbround18/valheim-docker

TODO: Check out https://hub.docker.com/r/lloesche/valheim-server as well - maybe more options/logging? Need some way to get count of players online

Is part of the [Kubic game server hosting](https://github.com/Cervator/KubicGameHosting) series started with https://github.com/Cervator/KubicArk and https://github.com/Cervator/KubicTerasology


## Instructions

Apply the resources to a target Kubernetes cluster with some attention paid to order (config maps and storage before the deployment). Consider using the `apply-server.sh` and `delete.sh` scripts

* `apply-server.sh valheim1` would create a server "valheim1" as configured in this repo
* `delete.sh valheim1` would then delete the valheim1 resources again

As the exposing of servers happen using a NodePort you need to manually add a firewall rule as well, Google Cloud example:

`gcloud compute firewall-rules create valheim1 --allow udp:31456-31458` would prepare the ports for valheim1

*Note:* There are placeholder passwords in `valheim-secrets.yaml` - you'll want to update these _but only locally where you run `kubectl` from_ - don't check your passwords into Git!


## Configuration files

To easily configure a given Valheim server via Git without touching the server several server config files are included via Kubernetes Config Maps (CMs)

* `adminlist.txt` - contains player entries to make admins automatically
* `bannedlist.txt` - players to prevent from connecting
* `permittedlist.txt` - players to allow connecting on a non-public server


### Making changes

After initial config and provisioning you can change the CMs either via files or directly, such as via the nice Google Kubernetes Engine dashboard. Then simply delete the server pod (not the deployment) via dashboard or eventually using ChatOps. The persistent volume survives including the installed game server files, so it may not make an appreciable difference to restart the server or blow it up. The deployment will auto-recreate the pod if deleted.


## Connecting to your server

Find an IP to one of your cluster nodes (the longer lived the better) by using `kubectl get nodes -o wide`, then add the right port from your server set, for instance `31457` (the "+1" port) for valheim1 `[IP]:[port]` then add that to the Steam server browser. The server generally comes online pretty fast but crashes easily, you can watch it with `kubectl logs <server-name>-<gibberish>` (adjust accordingly to your pod name, seen with `kubectl get pods`)


## Taking backups

You can take backups by either snapshotting the disk that's backing the Valheim persistent volume, copying the game files, or both. For instance in a terminal with `kubectl` configured, with the name of the Valheim pod handy, and in a directory you want to download the files to:

* `kubectl cp valheim1-64b954b5b-jmtmc:/home/steam/.config/unity3d/IronGate/Valheim/worlds/Dedicated.db Dedicated.db`
* `kubectl cp valheim1-64b954b5b-jmtmc:/home/steam/.config/unity3d/IronGate/Valheim/worlds/Dedicated.fwl Dedicated.fwl`


## License

This project is licensed under Apache v2.0 with contributions and forks welcome. The [Docker Image](https://github.com/mbround18/valheim-docker) used is licensed as per its project descriptions.
