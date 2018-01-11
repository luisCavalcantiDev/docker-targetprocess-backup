#!/bin/bash
set -e

# This script uses jq to parse JSON file which contains TargetProcess
# attachments metadata. jq documentation is at:
# http://xmodulo.com/how-to-parse-json-string-via-command-line-on-linux.html
# To see .json file pretty formatted and colored:
# cat $ATTACHMENTS_JSON | ./jq '.'
# After parsing the file, the TargetProcess attachments are downloaded.
# I discovered, there is no password or user needed for files download, but
# I provide them for the sake that it may be changed in the future.

BACKUP_DIR=$1

if [ -z "$BACKUP_DIR" ]; then
	echo "BACKUP_DIR not set, please pass it as command line argument"
  exit 1
fi
if [ ! -d "$BACKUP_DIR" ]; then
	echo "BACKUP_DIR is not a directory, please pass it as command line argument"
  exit 1
fi

"./verify_credentials.sh"

ATTACHMENTS_JSON="$BACKUP_DIR/attachments.json"
DOWNLOAD_DIR="$BACKUP_DIR/attachments"

echo "Installing jq to parse JSON..."
wget --quiet http://stedolan.github.io/jq/download/linux64/jq -O ./jq
chmod +x ./jq

ATTACHMENTS_COUNT=$(cat $ATTACHMENTS_JSON | ./jq '.[].Id' | wc -l)
echo "Will download $ATTACHMENTS_COUNT attachments into $DOWNLOAD_DIR"

mkdir -p $DOWNLOAD_DIR

for((n=0; n<$ATTACHMENTS_COUNT; n++))
{
  NAME=$(cat $ATTACHMENTS_JSON | ./jq ".[$n].Name")
  # get rid of first and last characters (quotes)
  NAME=${NAME:1:-1}
  URI=$(cat $ATTACHMENTS_JSON | ./jq ".[$n].Uri")
  # get rid of first and last characters (quotes)
  URI=${URI:1:-1}
  echo "Downloading $NAME from $URI"
  curl -X GET  --show-error -u $TP_USER:$TP_PASSWORD -o "$DOWNLOAD_DIR/$NAME" $URI
}
