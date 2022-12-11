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

One thing you need to configure inside a deployment instead is if you want to run with the Beta release, if one is live on Steam. Add a new environment variable to the normal section like so:

```
        - name: USE_PUBLIC_BETA
          value: "1"
```

### Making changes

After initial config and provisioning you can change the CMs either via files or directly, such as via the nice Google Kubernetes Engine dashboard. Then simply delete the server pod (not the deployment) via dashboard or eventually using ChatOps. The persistent volume survives including the installed game server files, so it may not make an appreciable difference to restart the server or blow it up. The deployment will auto-recreate the pod if deleted.


## Connecting to your server

Find an IP to one of your cluster nodes (the longer lived the better) by using `kubectl get nodes -o wide`, then add the right port from your server set, for instance `31457` (the "+1" port) for valheim1 `[IP]:[port]` then add that to the Steam server browser. The server generally comes online pretty fast but crashes easily, you can watch it with `kubectl logs <server-name>-<gibberish>` (adjust accordingly to your pod name, seen with `kubectl get pods`)


## Taking backups

You can take backups by either snapshotting the disk that's backing the Valheim persistent volume, copying the game files, or both. For instance in a terminal with `kubectl` configured, with the name of the Valheim pod handy, and in a directory you want to download the files to:

* `kubectl cp valheim1-64b954b5b-jmtmc:/home/steam/.config/unity3d/IronGate/Valheim/worlds/Dedicated.db Dedicated.db`
* `kubectl cp valheim1-64b954b5b-jmtmc:/home/steam/.config/unity3d/IronGate/Valheim/worlds/Dedicated.fwl Dedicated.fwl`

Another approach that's particularly helpful if you are juggling multiple servers and leave some offline and don't want to bring a game world live just to be able to get to the files normally is instead just using a utility pod mapped to just the persistent volume. Example:

```datapod.yml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: busybox
    command:
      - sleep
      - "3600"
    volumeMounts:
    - name: my-volume
      mountPath: /valheim1
  volumes:
  - name: my-volume
    persistentVolumeClaim:
      claimName: valheim1-pv-claim
```

* `kubectl apply -f datapod.yml` - create a pod using the above definition that'll mount the Valheim volume to `/valheim1`
* `kubectl cp my-pod:/valheim1/worlds/Dedicated.db Dedicated.db` - download the main world file
* `kubectl cp my-pod:/valheim1/worlds/Dedicated.fwl Dedicated.fwl` - download the other one
* `zip valheim1-2022-06-17.zip Dedicated.*` - zip them up into a single file
* `gsutil cp *.zip gs://game-server-backups/valheim/valheim1-2022-06-17` - upload them to a target Google Cloud Storage Bucket (must be created separately first and made public if desired)

## Restoring backups

You simply need to get the two world files from your desired backkup into the directory they normally live in - noting that for this specific setup the world file names will be "Dedicated" (as that is the designated world of the name as per config here). Have not tried figuring out the _easiest_ way yet to do this in Kubernetes, although the above approach should work in reverse.

Running a game _locally_ can be a little trickier as Valheim runs with worlds saved in the Steam cloud saves system by default, so the local directory may not exist. On a fairly modern instance of Windows the files should be placed at something like `C:\Users\[USERNAME]\AppData\LocalLow\IronGate\Valheim\worlds_local\` (naturally replacing "USERNAME" with your OS user) - files placed here should become visible in the worlds list even with cloud saves on.

## License

This project is licensed under Apache v2.0 with contributions and forks welcome. The [Docker Image](https://github.com/mbround18/valheim-docker) used is licensed as per its project descriptions.
