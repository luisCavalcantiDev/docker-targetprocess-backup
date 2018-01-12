# docker-targetprocess-backup

Docker image to backup [TargetProcess](https://www.targetprocess.com) entities.

## Specification
This project builds a docker image which is responsible for backing up
 TargetProcess entities like: User Stories, Features, Attachments, etc.
  The entities are saved into `.json` files, Attachments are downloaded.

It uses TargetProcess [REST API](https://md5.tpondemand.com/api/v1/index/meta).

### Backup directory structure
Backup files will be save into directory `/tmp/tp_backup/full`.
```
/tmp/tp_backup/full/
  attachments/
    my_attachment1.png
    my_attachment2.txt
  assignments_1_901.json        # metadata about attachments
  assignments_902_1802.json
  assignments_1803_2703.json
  ...
  attachments.json
  bugs_1_901.json
  bugs_902_1802.json
  ...
  builds_1_901.json
  ...
  context.json
  ...
```
The entities objects are sorted in descending order (except for Attachments for which that option does not work and there is a [public issue](https://tp3.uservoice.com/forums/174654-we-will-rock-you/suggestions/6312209-improve-rest-api-support-operations-for-attachmen) for that).
For each entity type which is backuped, there is a javascript file in `./entities` directory. Additionally: all the views are backuped using `curl`.

### The entities not backuped
Dashboards are not backuped. But they are made of views, reports and groups (directories), which are backuped.

## Usage
This is a short-running image, it will stop after its job is done.
Results will be saved to: `/tmp/tp_backup/full`.

There are 2 possibilities to run it.


### Credentials as environment variables
Choose some user who is a TargetProcess Admin and then pass its credentials
 either as environment variables:
```
docker run -ti --volume=/tmp/tp_backup:/tmp/tp_backup\
  --env TP_DOMAIN="mydomain.tpondemand.com"\
  --env TP_USER="TODO" --env TP_PASSWORD="TODO"\
  xmik/targetprocess-backup
```

### Credentials from file
Choose some user who is a TargetProcess Admin and then write its credentials
to a local file which will be accessible in the docker container as: `/tmp/tp_backup/credentials.sh`. E.g.
```
$ cat /tmp/tp_backup/credentials.sh
#!/bin/bash

export TP_DOMAIN="mydomain.tpondemand.com"
export TP_USER="TODO"
export TP_PASSWORD="TODO"
```
and then run the container:
```
docker run -ti --volume=/tmp/tp_backup:/tmp/tp_backup xmik/targetprocess-backup
```

### Usage - test
If you want to just try this docker image out or verify if you have set up
 your credentials right and that you can connect to TargetProcess API,
 run the container
 with additional environment variable: `-e TEST=true`.

This will only backup some TargetProcess Features (in contrast to backing up
  all the TargetProcess entities). Result will be saved to: `/tmp/tp_backup/test`.
  You can choose other TargetProcess entities to experiment on, do it in
  `./image/backup/run.sh` file.

### Tar
To compress the backup:
```
$ cd /tmp
/tmp$ tar -czf tp_backup-$(date +%Y-%m-%d).tar.gz tp_backup/
```

## Development
### Dependencies
* Bash
* Docker daemon
* Bats

### Lifecycle
1. In a feature branch:
    * you make changes
    * you build docker image: `./tasks build`
    * and test it: `TP_USER=TODO TP_PASSWORD=TODO TP_DOMAIN=TODO ./tasks test`
1. You decide that your changes are ready and you:
    * merge into master branch
    * bump version in CHANGELOG and version file with:
      * `./tasks set_version` - will bump patch number
      * or. `./tasks set_version 1.2.3` will set version to 1.2.3
    * push to master
1. Automated docker build on hub.docker.com will build and push the image

### Experiments
See [README_experiments.md](./README_experiments.md)

## License

Licensed under the MIT license. See LICENSE for details.
