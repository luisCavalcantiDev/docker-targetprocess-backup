### 1.0.1 (2018-Jan-12)

* add option: UPPER_ID to set the highest expected Id of a TargetProcess entity, defaults to 16000 #2
* do not print `Errors from the request: null` after each request, print error
 only if it was truthy #3
* catch more errors from http requests

### 1.0.0 (2018-Jan-11)

* new directories structure: `image/`
* added `tasks` file for easier development
* tests can be run with 1 bash command
* update dependencies:
   * nodejs=9.4.0-1nodesource1
   * tp-api=1.2.2
   * debian:stretch-slim
* make it easier to experiment with: install tp-api globally
* fix downloading attachments #1 (there is no more Uri field when getting
  attachments through TargetProcess REST API)
* renamed git repo to docker-targetprocess-backup

### 0.0.3

* fix bug: in docker cannot remove `/tmp/tp_backup` when it is mounted as a docker volume
* make `test_run.sh` closer to production `run.sh`: remove and create the backup directory

### 0.0.2

* support running in Docker
* take credentials from 1 source instead of 2

### 0.0.1

Initial release.
