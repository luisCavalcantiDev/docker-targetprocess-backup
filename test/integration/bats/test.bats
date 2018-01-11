load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'
load 'variables'

function clean_func(){
  if [[ "${volumes_root}" == "" ]]; then
    echo "fail! volumes_root not set"
    return 1 # TODO: exit here
  fi
  if [[ "${TP_DOMAIN}" == "" ]]; then
    echo "fail! TP_DOMAIN not set"
    return 1 # TODO: exit here
  fi
  if [[ "${this_image_name}" == "" ]]; then
    echo "fail! this_image_name not set"
    return 1 # TODO: exit here
  fi
  if [[ "${this_image_tag}" == "" ]]; then
    echo "fail! this_image_tag not set"
    return 1 # TODO: exit here
  fi
  docker stop ${cont} || echo "No ${cont} container to stop"
  docker rm ${cont} || echo "No ${cont} container to remove"
  sudo rm -rf "${volumes_root}"
  # those directories will be cinder volumes, so make this closer to production
  mkdir -p "${volume_data}/lost+found"
}

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
  assert_equal "$status" 1
}
@test "clean before test" {
  clean_func
}
@test "backup works if credentials set" {
  docker run --name ${cont} -ti \
    --env TEST=true \
    --env TP_DOMAIN="${TP_DOMAIN}" \
    --env TP_USER="${TP_USER}"\
    --env TP_PASSWORD="${TP_PASSWORD}" \
    -v ${volume_data}:/tmp/tp_backup \
    "${this_image_name}:${this_image_tag}"

  run docker logs ${cont}
  assert_equal "$status" 0
  refute_output --partial "not set, please set it"
  assert_output --partial "Success, downloaded features of ids: 2700 to 2800 into /tmp/tp_backup/test/test.json"

  run test -f ${volume_data}/test/test.json
  assert_equal "$status" 0

  run cat ${volume_data}/test/test.json
  assert_equal "$status" 0
  assert_output --partial "\"Name\":\"Feature\""
}
@test "clean after test" {
  clean_func
}
