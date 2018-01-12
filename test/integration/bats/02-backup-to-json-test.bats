load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'
load 'variables'

# The tests here do not connect with TP API, so let's use fake credentials

@test "clean before test" {
  clean_func
}
@test "backup_to_json works" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="dummy.example.com" \
    --env TP_USER="someuser" \
    --env TP_PASSWORD="somepassword" \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}" \
    "source /opt/tp_backup/run_functions.sh && mkdir -p \$BACKUP_DIR && verify_credentials && backup_to_json"
  assert_output --partial "Credentials verified"
  refute_output --partial "not set, please set it"
  assert_output --partial "Backing up bugs from Id: 1 to: 901 into /tmp/tp_backup/test/bugs_1_901.json"
  assert_output --partial "Backing up bugs from Id: 15318 to: 16218 into /tmp/tp_backup/test/bugs_15318_16218.json"
  assert_output --partial "Backing up: attachments into /tmp/tp_backup/test/attachments.json"
  assert_equal "$status" 0

  run test -f ${volume_data}/test/bugs_1_901.json
  assert_equal "$status" 0

  run test -f ${volume_data}/test/attachments.json
  assert_equal "$status" 0
}
@test "clean after test" {
  clean_func
}
