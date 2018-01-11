# targetprocess-backup

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


### Verification
An easy test is to use the `jq` program, which is downloaded by `run.sh`, so it should be in the current directory after backuping.

To get all the IDs of some entity objects in a file:
```
$ cat /tmp/tp_backup/full/features_2704_3604.json | ./jq '.[].Id'
```
To get names:
```
$ cat /tmp/tp_backup/full/features_6308_7208.json | ./jq '.[].Name'
```

### Details
*You don't have to read it if you only want to create backup*

#### Backup only Features
Each entity type that will be backuped has its own file in `./entities` directory. Example file is: `./entities/features.js`. That file takes 2 command line parameters: the start ID and the end ID. They specify a range (inclusive) in which we look for entity objects. Each of those files in `./entities` directory can be invoked separately. For example, to backup features of IDs from 100 to 150, run:
```
$ nodejs entities/features.js 100 150
```
In order to redirect the stdout to a file:
```
$ nodejs entities/features.js 100 150 > /tmp/tp_features_100_to_150.json
```
There is still stderr, which if all goes fine shows:
```
Errors from the request:  null
```
Some of those files do not take parameters, because there are so few of such entities objects (e.g. we have 2 Roles) and we backup them all at once.

#### Why the ranges
As written on [dev.targetprocess.com](http://dev.targetprocess.com/rest/response_format): "You can not have more then 1000 items per request. If you set 'take' parameter greater than 1000, it will be treated as 1000 (including link generation)". Also, despite of Features, Tasks, UserStories and similar entities sharing the same Id assignments, the entities like e.g.: Assignments has its own Ids assignments (there can be Feature with Id = 3 and Assignment with Id = 3), so to make the number even (not to backup 999 entities objects at once) and to be more safe, we backup up to 900, not 1000 entities in 1 request.

In order not to make the main script too complicated, I use those ranges for all entities for which I can. Each request response is saved to one file.

By default, a request takes 25 entities objects.

#### Why the `.append()` method
In order to make the backup restore, in the future, easier, I decided to get additional fields for some enitities objects. Example: `Bugs-Count` or `Comments-Count`. So that we can perform some verification that we matched e.g. all the Bugs for a UserStory.

#### Attachments
There is some trouble around getting Attachments (#7537 and [this open bug](https://tp3.uservoice.com/forums/174654-we-will-rock-you/suggestions/6312209-improve-rest-api-support-operations-for-attachmen)), in result we can:
  * get metadata about 1 attachment at a time using curl
  * get metadata about all attachments at a time using curl
  * get metadata about all attachments at a time using `tp-api`

Since we have less than 60 attachments (28th October 2015), it is ok to get metadata about them all at once. I don't think this will change. Each of them is downloaded separately anyway.

## Development

Please read the [TP_API_knowledge_base.md](TP_API_knowledge_base.md), it contains examples using `tp-api` and `curl`.

### Experiments
Use the file `test.js` to experiment using `tp-api`:
```
$ nodejs ./test/test.js
```
or the file `test.sh` to experiment using `curl`:
```
$ ./test/test.sh
```
Those files are intended to be standalone (not depend on any other files).

### Use newer `tp-api` version
If you want to use unreleased `tp-api` version, instead of
```
$ npm install tp-api
```
run:
```
$ mkdir -p node_modules/ && cd node_modules/
$ git clone https://github.com/8bitDesigner/tp-api.git && cd tp-api/
$ npm install
```

## License

Licensed under the MIT license. See LICENSE for details.
