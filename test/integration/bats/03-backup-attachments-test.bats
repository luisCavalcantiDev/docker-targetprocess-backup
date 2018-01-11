load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'
load 'variables'

@test "clean before test" {
  clean_func
}
@test "download_attachments fails if attachments.json does not exist" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="${TP_DOMAIN}" \
    --env TP_USER="${TP_USER}" \
    --env TP_PASSWORD="${TP_PASSWORD}" \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}" \
    "source /opt/tp_backup/run_functions.sh && mkdir -p \$BACKUP_DIR && download_attachments"
  assert_output --partial "The expected file does not exist: /tmp/tp_backup/test/attachments.json"
  refute_output --partial "Error"
  assert_equal "$status" 1
}

@test "clean before test" {
  clean_func
}
@test "download_attachments works if attachments.json exists" {
  # This test really downloads 3 attachments, but they are small. The 3rd one
  # with ID=22 is a kernel panic output saved onto txt file. Here we verify
  # its contents.
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="${TP_DOMAIN}" \
    --env TP_USER="${TP_USER}" \
    --env TP_PASSWORD="${TP_PASSWORD}" \
    -v $(pwd)/test/test-files/attachments.json:/tmp/tp_backup/test/attachments.json \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}" \
    "source /opt/tp_backup/run_functions.sh && mkdir -p \$BACKUP_DIR && download_attachments"
  refute_output --partial "file does not exist"
  refute_output --partial "Error"
  assert_output --partial "Will download 3 attachments into"
  assert_equal "$status" 0

  run test -f ${volume_data}/test/attachments/sth.txt
  assert_equal "$status" 0

  run cat ${volume_data}/test/attachments/sth.txt
  assert_equal "$status" 0
  assert_output --partial "This is the actual line which caused the NULL pointer dereference"
}
