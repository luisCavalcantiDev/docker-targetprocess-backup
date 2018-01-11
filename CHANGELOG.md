### 1.0.0 (2018-Jan-11)

* new directories structure: `image/`
* added `tasks` file for easier development
* tests can be run with 1 bash command
* update dependencies:
   * nodejs=9.4.0-1nodesource1
   * tp-api=1.2.2
   * debian:stretch-slim
* make it easier to experiment with: install tp-api globally

### 0.0.3

* fix bug: in docker cannot remove `/tmp/tp_backup` when it is mounted as a docker volume
* make `test_run.sh` closer to production `run.sh`: remove and create the backup directory

### 0.0.2

* support running in Docker
* take credentials from 1 source instead of 2

### 0.0.1

Initial release.
