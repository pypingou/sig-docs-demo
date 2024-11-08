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

if ! sudo podman image exists localhost/auto-apps:latest ; then
    echo "Running Stage 3 to generate the RPM and container images needed for this stage"
    pushd ../stage3_local_container
    sh build.sh --noimage
    popd
else
    echo "Container image found"
fi

p=$PATH
arch=$(arch)

if [ $image = true ]; then

    source /etc/os-release
    sid="autosd"
    if [ $ID == "fedora" ]; then
      sid="f"
    fi

   sudo env "PATH=$PATH" automotive-image-builder --verbose --container \
    --include=/var/lib/containers/storage/ \
    build \
    --distro $sid$VERSION_ID \
    --target qemu \
    --mode image \
    --build-dir=_build \
    --export qcow2 \
    quadlet.mpp.yml \
    quadlet.$arch.qcow2
fi

