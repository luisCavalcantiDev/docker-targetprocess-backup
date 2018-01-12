#!/bin/bash
set -e

START_DATE=$(date)
# explicitly run this function when this script is stopped
cleanup() {
  exit_status=$?
  END_DATE=$(date)
  if [[ "${exit_status}" -eq 0 ]]; then
    echo "TargetProcess-backup: Success. Started at $START_DATE finished at $END_DATE"
    exit 0
  fi
  echo "TargetProcess-backup: Failure. Caught INT or TERM or EXIT, running cleanup. Started at $START_DATE finished at $END_DATE"
  exit 1
}
trap cleanup INT TERM EXIT

# http://mywiki.wooledge.org/BashFAQ/028
# step into the directory with this script in order to use relative
# paths to other scripts
cd "${BASH_SOURCE%/*}" || { echo "cannot cd into ${BASH_SOURCE%/*}"; exit 1; }
source ./run_functions.sh

echo "TargetProcess-backup: Started"
echo "TargetProcess-backup: BACKUP_DIR set to: ${BACKUP_DIR}"
echo "TargetProcess-backup: UPPER_ID set to: ${UPPER_ID}"

if [[ "${DO_NOT_REMOVE_BACKUP_DIR}" != "true" ]]; then
  rm -rf $BACKUP_DIR
fi
mkdir -p $BACKUP_DIR
# this creates a file in $BACKUP_DIR, so must go after creating $BACKUP_DIR
verify_credentials
backup_to_json
download_attachments
