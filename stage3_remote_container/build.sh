#!/usr/bin/bash

image=true
while [[ $# -gt 0 ]]; do
  case $1 in
    --noimage)
      image=false
      shift # past argument
      ;;
  esac
done

set -xe

arch=$(arch)

if [ $image = true ]; then
  source /etc/os-release

  sid="autosd"
  if [ $ID == "fedora" ]; then
    sid="f"
  fi

  automotive-image-builder --verbose --container \
    --include=/var/lib/containers/storage/ \
    build \
    --distro $sid$VERSION_ID \
    --target qemu \
    --mode image \
    --build-dir=_build \
    --export qcow2 \
    remote_container.mpp.yml \
    remote_container.$arch.qcow2
fi

