load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'
load 'variables'

@test "clean before test" {
  clean_func
}
@test "backup fails if TP_USER not set" {
  run docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="${TP_DOMAIN}" \
    --env TP_PASSWORD="${TP_PASSWORD}" \
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
    --env TP_DOMAIN="${TP_DOMAIN}" \
    --env TP_USER="${TP_USER}" \
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
    --env TP_USER="${TP_USER}" \
    --env TP_PASSWORD="${TP_PASSWORD}" \
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
    --env TP_DOMAIN="${TP_DOMAIN}" \
    --env TP_USER="${TP_USER}" \
    --env TP_PASSWORD="${TP_PASSWORD}" \
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
  echo "export TP_DOMAIN=\"${TP_DOMAIN}\"" >> ${volume_data}/credentials.sh
  echo "export TP_USER=\"${TP_USER}\"" >> ${volume_data}/credentials.sh
  echo "export TP_PASSWORD=\"${TP_PASSWORD}\"" >> ${volume_data}/credentials.sh

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
