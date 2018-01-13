load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'
load 'variables'

@test "clean before test" {
  clean_func
}
# we have to set DO_NOT_REMOVE_BACKUP_DIR=true, because we mount /tmp/tp_backup/test/attachments.json
@test "backup works with credentials set as environment variables" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env UPPER_ID=4000 \
    --env DO_NOT_REMOVE_BACKUP_DIR=true \
    --env TP_DOMAIN="${TP_DOMAIN}" \
    --env TP_USER="${TP_USER}" \
    --env TP_PASSWORD="${TP_PASSWORD}" \
    -v $(pwd)/test/test-files/attachments.json:/tmp/tp_backup/test/attachments.json \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}"
  assert_output --partial "TargetProcess-backup: Success"
  assert_output --partial "Backing up all the entities"
  assert_output --partial "Will download 3 attachments into"
  assert_output --partial "BACKUP_DIR set to: /tmp/tp_backup/test"
  assert_output --partial "UPPER_ID set to: 4000"
  assert_equal "$status" 0

  run test -f ${volume_data}/test/attachments/sth.txt
  assert_equal "$status" 0

  run cat ${volume_data}/test/attachments/sth.txt
  assert_equal "$status" 0
  assert_output --partial "This is the actual line which caused the NULL pointer dereference"
}
@test "clean before test" {
  clean_func
}
# we have to set DO_NOT_REMOVE_BACKUP_DIR=true, because we mount /tmp/tp_backup/test/attachments.json
@test "backup works with credentials set in a file" {
  echo "#!/bin/bash" > ${volume_data}/credentials.sh
  echo "export TP_DOMAIN=\"${TP_DOMAIN}\"" >> ${volume_data}/credentials.sh
  echo "export TP_USER=\"${TP_USER}\"" >> ${volume_data}/credentials.sh
  echo "export TP_PASSWORD=\"${TP_PASSWORD}\"" >> ${volume_data}/credentials.sh

  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env DO_NOT_REMOVE_BACKUP_DIR=true \
    -v $(pwd)/test/test-files/attachments.json:/tmp/tp_backup/test/attachments.json \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}"
  assert_output --partial "TargetProcess-backup: Success"
  assert_output --partial "Backing up all the entities"
  assert_output --partial "Will download 3 attachments into"
  assert_output --partial "BACKUP_DIR set to: /tmp/tp_backup/test"
  assert_output --partial "UPPER_ID set to: 16000"
  assert_equal "$status" 0

  run test -f ${volume_data}/test/attachments/sth.txt
  assert_equal "$status" 0

  run cat ${volume_data}/test/attachments/sth.txt
  assert_equal "$status" 0
  assert_output --partial "This is the actual line which caused the NULL pointer dereference"
}
@test "clean after test" {
  clean_func
}
