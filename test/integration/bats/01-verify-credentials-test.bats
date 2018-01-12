load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'
load 'variables'

# The tests here do not connect with TP API, so let's use fake credentials

@test "clean before test" {
  clean_func
}
@test "backup fails if TP_USER not set" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="dummy.example.com" \
    --env TP_PASSWORD="somepassword" \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}"
  assert_output --partial "TP_USER not set, please set it"
  refute_output --partial "Error"
  assert_equal "$status" 1
}
@test "clean before test" {
  clean_func
}
@test "backup fails if TP_PASSWORD not set" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="dummy.example.com" \
    --env TP_USER="someuser" \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}"
  assert_output --partial "TP_PASSWORD not set, please set it"
  refute_output --partial "Error"
  assert_equal "$status" 1
}
@test "clean before test" {
  clean_func
}
@test "backup fails if TP_DOMAIN not set" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_USER="someuser" \
    --env TP_PASSWORD="somepassword" \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}"
  assert_output --partial "TP_DOMAIN not set, please set it"
  refute_output --partial "Error"
  assert_equal "$status" 1
}
@test "clean before test" {
  clean_func
}
@test "verify_credentials succeeds if credentials set with env variables" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="dummy.example.com" \
    --env TP_USER="someuser" \
    --env TP_PASSWORD="somepassword" \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}" \
    "source /opt/tp_backup/run_functions.sh && verify_credentials"
  assert_output --partial "Credentials verified"
  refute_output --partial "Error"
  assert_equal "$status" 0
}
@test "clean before test" {
  clean_func
}
@test "verify_credentials succeeds if credentials set in a file" {
  echo "#!/bin/bash" > ${volume_data}/credentials.sh
  echo "export TP_DOMAIN=\"dummy.example.com\"" >> ${volume_data}/credentials.sh
  echo "export TP_USER=\"someuser\"" >> ${volume_data}/credentials.sh
  echo "export TP_PASSWORD=\"somepassword\"" >> ${volume_data}/credentials.sh

  run docker run --name ${cont} -ti \
    --env TEST=true \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}" \
    "source /opt/tp_backup/run_functions.sh && verify_credentials"
  assert_output --partial "Sourcing credentials from file"
  assert_output --partial "Credentials verified"
  refute_output --partial "Error"
  assert_equal "$status" 0
}
@test "clean after test" {
  clean_func
}
