service_name="tp-backup"
volumes_root="/tmp/${service_name}-itest"
volume_data="/tmp/${service_name}-itest/data"
cont="${service_name}-itest"

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
