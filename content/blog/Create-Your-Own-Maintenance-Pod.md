---
title: 'Create your own maintenance pod'
date: 2022-11-09
draft: false
tags: [blog, pvc, kubernetes, cloud]
---

Intro
-----

So the other day i tried to update my k3s cluster running at the Oracle Clud. Somehow, my Postgres `statefulset` crashed and the `postmaster.pid` file was not removed properly. Anyway, the pod was restarted but was now in a `CrashLoopBackOff` stage. The error message stated that the lock file couldn´t be removed. So how do you remove a file from a `PersistentVolumeClaim` with the container constantly restarting? I found something.

## `CrashLoopBackOff`

The `CrashLoopBackOff` status of a pod is a nasty one. You have to look at the log files if you would like to know more. So in my case i had to look at the postgres logs:

```bash
 k logs -n postgres postgres-0
Defaulted container "postgres" out of: postgres, postgres-init (init)
chmod: changing permissions of '/var/lib/postgresql/data/pg': Read-only file system

PostgreSQL Database directory appears to contain a database; Skipping initialization

2022-11-09 19:20:05.485 UTC [1] FATAL:  could not remove old lock file "postmaster.pid": Read-only file system
2022-11-09 19:20:05.485 UTC [1] HINT:  The file seems accidentally left over, but it could not be removed. Please remove the file by hand and try again.
```

## stale lock file

So, the lock, or pid file, was stale, and couldn't be removed. After some thinking i came up with a solution. A maintenance pod!. With that pod i will mount the `pvc` called `postgres-data-postgres-0` and remove the file manually.

## Getting it done

First, one needs to scale down the postgres `statefulset` so it would not mount the `pvc`. So, lets do that:

```bash
❯ kubectl scale statefulset -n postgres postgres --replicas=0
statefulset.apps/postgres scaled
```

After that, i created a `deployment` called `maintenancepod`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: maintenancepod
  name: maintenancepod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: maintenancepod
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: maintenancepod
    spec:
      containers:
      - image: alpine
        name: maintenance
        command: ["/bin/sh", "-c", "--"]
        args: ["while true; do sleep 30; done;"]
        resources: {}
        volumeMounts:
          - mountPath: /data
            name: pg-data
      volumes:
        - name: pg-data
          persistentVolumeClaim:
            claimName: postgres-data-postgres-0
status: {}
```

With this `deployment` a pod will be created which will run a `sleep` indefinitely so the pod will just keep running, and it will mount the `persistentVolumeClaim` with the name `postgres-data-postgres-0` to mount path `/data`.

So now, let's apply the maintenance pod:

```bash
❯ kubectl apply -f maintenancepod.yaml
deployment.apps/maintenancepod created
```

after that, i can enter the pod by running the `kubectl exec` command.

```bash
❯ kubectl exec -it maintenancepod-9f5cfd7b4-8shqh -- /bin/sh
/ # 
```

So now, let's navigate to the `/data/pg` directory.
```bash

/ # cd /data/pg/
/data/pg # ls
PG_VERSION            pg_commit_ts          pg_ident.conf         pg_notify             pg_snapshots          pg_subtrans           pg_wal                postgresql.conf
base                  pg_dynshmem           pg_logical            pg_replslot           pg_stat               pg_tblspc             pg_xact               postmaster.opts
global                pg_hba.conf           pg_multixact          pg_serial             pg_stat_tmp           pg_twophase           postgresql.auto.conf  postmaster.pid

/data/pg # rm postmaster.pid
/data/pg #
```

So the file is gone now and we can terminate the deployment:

```bash
❯ kubectl delete -f maintenancepod.yaml
deployment.apps "maintenancepod" deleted
```

After that, we can scale the `replica` of the `statefulset` back up to it's original value, `1`.

```bash
❯ kubectl scale statefulset -n postgres postgres --replicas=1
statefulset.apps/postgres scaled
```

After a while, postgres was started again, without any problems:

```bash
❯ kubectl get pod
NAME         READY   STATUS    RESTARTS   AGE
postgres-0   1/1     Running   0          2m21s
```

Problem solved :)