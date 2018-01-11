#!/bin/bash
set -e

if [[ -n "${TEST}" ]]; then
  BACKUP_DIR="/tmp/tp_backup/test"
else
  BACKUP_DIR="/tmp/tp_backup/full"
fi

# http://mywiki.wooledge.org/BashFAQ/028
# step into the directory with this script in order to use relative
# paths to other scripts
cd "${BASH_SOURCE%/*}" || exit

if [ -f "./credentials.sh" ]; then
  source "./credentials.sh"
fi

"./verify_credentials.sh"

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

START_DATE=$(date)

rm -rf $BACKUP_DIR
mkdir -p $BACKUP_DIR

if [[ -n "${TEST}" ]]; then
  BACKUP_FILE="${BACKUP_DIR}/test.json"
  nodejs ./entities/features.js 2700 2800 > $BACKUP_FILE
  echo "Success, downloaded features of ids: 2700 to 2800 into $BACKUP_FILE"
  END_DATE=$(date)
  echo "Done. Started at $START_DATE finished at $END_DATE"
  exit 0
fi

# Download metadata about those entities in many requests (each containing less
# than 1000 items), because there are a lot of those entities objects.
declare -a ENTITIES=("assignments" "bugs" "builds" "comments" "epics" \
  "features" "impediments" "iterations" "relations" "releases" "requests" \
  "tasks" "team_iterations" "times" "user_stories")

ID_RANGE_START='1'
ID_RANGE_INCREMENT='900' # the first file contains assignments from 1 to 900

# loop through the above array with ENTITIES
for e in "${ENTITIES[@]}"
do
  ENTITY="$e"
  echo "Backuping $ENTITY"
  # loop through the above array with ID_RANGES_STARTS
  while [ $ID_RANGE_START -le '11000' ] ; do
    CURRENT_RANGE_START=$ID_RANGE_START
    # here we add $ID_RANGE_INCREMENT to $CURRENT_RANGE_START
    CURRENT_RANGE_END=$(($CURRENT_RANGE_START + $ID_RANGE_INCREMENT))
    BACKUP_FILE="${BACKUP_DIR}/${ENTITY}_${CURRENT_RANGE_START}_${CURRENT_RANGE_END}.json"
    echo "Backuping $ENTITY from: $CURRENT_RANGE_START to: $CURRENT_RANGE_END into $BACKUP_FILE"
    # comment the line below for dry run
    nodejs entities/$ENTITY.js ${CURRENT_RANGE_START} ${CURRENT_RANGE_END} > ${BACKUP_FILE}
    ID_RANGE_START=$(($CURRENT_RANGE_END + 1))
  done
  ID_RANGE_START='1'
done

# Download metadata about those entities all at once (e.g. all roles at once),
# because there are very few of them and should never grow.
# Only <60 attachments (27th October 2015)
declare -a SMALL_ENTITIES=("attachments" "context" "custom_rules" "processes" \
  "programs" "projects" "roles" "teams" "team_projects" "workflows")

# loop through the above array with SMALL_ENTITIES
for e in "${SMALL_ENTITIES[@]}"
do
  SMALL_ENTITY="$e"
  BACKUP_FILE="${BACKUP_DIR}/${SMALL_ENTITY}.json"
  echo "Backuping $SMALL_ENTITY into $BACKUP_FILE"
  # comment the line below for dry run
  nodejs entities/$SMALL_ENTITY.js > ${BACKUP_FILE}
done

VIEWS_BACKUP_FILE="$BACKUP_DIR/views.json"
echo "Backuping up views into $VIEWS_BACKUP_FILE"
# comment the line below for dry run
curl -X GET -u $TP_USER:$TP_PASSWORD "https://$TP_DOMAIN/api/views/v1/?take=1000&format=json" > ${VIEWS_BACKUP_FILE}
# comment the line below for dry run
./download_attachments.sh $BACKUP_DIR

END_DATE=$(date)
echo "Done. Started at $START_DATE finished at $END_DATE"
