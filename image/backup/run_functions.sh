#!/bin/bash
set -e

if [[ -n "${TEST}" ]]; then
  BACKUP_DIR="${BACKUP_DIR:-/tmp/tp_backup/test}"
else
  BACKUP_DIR="${BACKUP_DIR:-/tmp/tp_backup/full}"
fi
UPPER_ID="${UPPER_ID:-16000}"
CREDENTIALS_FILE="$(readlink -m ${BACKUP_DIR}/../credentials.sh)"

# http://mywiki.wooledge.org/BashFAQ/028
# step into the directory with this script in order to use relative
# paths to other scripts
cd "${BASH_SOURCE%/*}" || { echo "cannot cd into ${BASH_SOURCE%/*}"; exit 1; }

function verify_credentials() {
  if [ -f "${CREDENTIALS_FILE}" ]; then
    echo "Sourcing credentials from file"
    source "${CREDENTIALS_FILE}"
  fi

  if [ -z "$TP_USER" ]; then
  	echo "TP_USER not set, please set it as env variable or in ${CREDENTIALS_FILE}, return 1"
    return 1
  fi
  if [ -z "$TP_PASSWORD" ]; then
  	echo "TP_PASSWORD not set, please set it as env variable or in ${CREDENTIALS_FILE}, return 1"
    return 1
  fi
  if [[ "$TP_PASSWORD" == "TODO" ]]; then
  	echo "TP_PASSWORD not set, please set it as env variable or in ${CREDENTIALS_FILE}, return 1"
    return 1
  fi
  if [ -z "$TP_DOMAIN" ]; then
  	echo "TP_DOMAIN not set, please set it as env variable or in ${CREDENTIALS_FILE}, return 1"
    return 1
  fi

  # generate js file with credentials
  echo "var tp = require('tp-api')({
             domain:   '$TP_DOMAIN',
             username: '$TP_USER',
             password: '$TP_PASSWORD'
           })


  // export the variable
  // http://stackoverflow.com/questions/3922994/share-variables-between-files-in-node-js
  exports.tp = tp;
  " > "./credentials.js"
  echo "Credentials verified"
}

function backup_to_json() {
  echo "Backing up all the entities"
  # Download metadata about those entities in many requests (each containing less
  # than 1000 items), because there are a lot of those entities objects.
  declare -a ENTITIES=("assignments" "bugs" "builds" "comments" "epics" \
    "features" "impediments" "iterations" "relations" "releases" "requests" \
    "tasks" "team_iterations" "times" "user_stories")

  ID_RANGE_START='1'
  ID_RANGE_INCREMENT='900' # the first file contains entities from 1 to 900

  # loop through the above array with ENTITIES
  for e in "${ENTITIES[@]}"
  do
    ENTITY="$e"
    echo "Backing up $ENTITY"
    # loop through the above array with ID_RANGES_STARTS
    while [ $ID_RANGE_START -le "${UPPER_ID}" ] ; do
      CURRENT_RANGE_START=$ID_RANGE_START
      # here we add $ID_RANGE_INCREMENT to $CURRENT_RANGE_START
      CURRENT_RANGE_END=$(($CURRENT_RANGE_START + $ID_RANGE_INCREMENT))
      BACKUP_FILE="${BACKUP_DIR}/${ENTITY}_${CURRENT_RANGE_START}_${CURRENT_RANGE_END}.json"
      echo "Backing up $ENTITY from Id: $CURRENT_RANGE_START to: $CURRENT_RANGE_END into $BACKUP_FILE"
      if [[ -n "${TEST}" ]]; then
        touch ${BACKUP_FILE}
      else
        nodejs entities/$ENTITY.js ${CURRENT_RANGE_START} ${CURRENT_RANGE_END} > ${BACKUP_FILE}
      fi
      ID_RANGE_START=$(($CURRENT_RANGE_END + 1))
    done
    ID_RANGE_START='1'
  done

  # Download metadata about those entities in 1 request (e.g. all roles at once),
  # because there are very few of them and should never grow.
  # Only <60 attachments (27th October 2015)
  declare -a SMALL_ENTITIES=("attachments" "context" "custom_rules" "processes" \
    "programs" "projects" "roles" "teams" "team_projects" "workflows")

  # loop through the above array with SMALL_ENTITIES
  for e in "${SMALL_ENTITIES[@]}"
  do
    SMALL_ENTITY="$e"
    BACKUP_FILE="${BACKUP_DIR}/${SMALL_ENTITY}.json"
    echo "Backing up: ${SMALL_ENTITY} into ${BACKUP_FILE}"
    if [[ -n "${TEST}" ]]; then
      touch ${BACKUP_FILE}
    else
      nodejs entities/${SMALL_ENTITY}.js > ${BACKUP_FILE}
    fi
  done

  VIEWS_BACKUP_FILE="${BACKUP_DIR}/views.json"
  echo "Backing up views into ${VIEWS_BACKUP_FILE}"
  if [[ -n "${TEST}" ]]; then
    touch ${VIEWS_BACKUP_FILE}
  else
    curl -X GET -u $TP_USER:$TP_PASSWORD "https://${TP_DOMAIN}/api/views/v1/?take=1000&format=json" > ${VIEWS_BACKUP_FILE}
  fi
}

function download_attachments {
  ATTACHMENTS_JSON="${BACKUP_DIR}/attachments.json"
  DOWNLOAD_DIR="${BACKUP_DIR}/attachments"
  if [[ ! -f "${ATTACHMENTS_JSON}" ]]; then
  	echo "The expected file does not exist: ${ATTACHMENTS_JSON}, return 1"
  	return 1
  fi
  ATTACHMENTS_COUNT=$(cat $ATTACHMENTS_JSON | jq '.[].Id' | wc -l)
  echo "Will download $ATTACHMENTS_COUNT attachments into $DOWNLOAD_DIR"
  mkdir -p $DOWNLOAD_DIR

  for((n=0; n<$ATTACHMENTS_COUNT; n++))
  {
    ATTACHMENT_NAME=$(cat $ATTACHMENTS_JSON | jq -r ".[$n].Name")
  	if [[ -z "${ATTACHMENT_NAME}" ]]; then
  		echo "ATTACHMENT_NAME is not set, exit 1"
  		return 1
  	fi
    ATTACHMENT_ID=$(cat $ATTACHMENTS_JSON | jq -r ".[$n].Id")
  	if [[ -z "${ATTACHMENT_ID}" ]]; then
  		echo "ATTACHMENT_ID is not set, exit 1"
  		return 1
  	fi
    echo "Downloading attachment: ${ATTACHMENT_ID}/${ATTACHMENTS_COUNT}, name: ${ATTACHMENT_NAME}"
    curl --silent -X GET --show-error -u $TP_USER:$TP_PASSWORD -o "${DOWNLOAD_DIR}/${ATTACHMENT_NAME}" https://$TP_DOMAIN/Attachment.aspx?AttachmentID=${ATTACHMENT_ID}
  }
}
