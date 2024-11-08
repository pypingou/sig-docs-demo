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

if [ ! -d "/var/tmp/my_repo" ]; then
    echo "Running Stage 1 to generate the RPM and RPM repository needed for this stage"
    pushd ../stage1_rpmbuild
    sh build.sh --noimage
    popd
fi

# First copy locally the RPM repository
# This is required as we cannot copy into the container files that are local but
# not placed in the folder where the container is built.
cp -r /var/tmp/my_repo .

source /etc/os-release

sid="autosd"
if [ $ID == "fedora" ]; then
  sid="f"
fi

sudo podman build -t localhost/auto-apps:latest -f Containerfile.$sid$VERSION_ID

sudo podman run -it auto-apps rpm -q auto-apps
p=$PATH
arch=$(arch)


if [ $image = true ]; then

   sudo env "PATH=$PATH" automotive-image-builder --verbose --container \
    --include=/var/lib/containers/storage/ \
    build \
    --distro $sid$VERSION_ID \
    --target qemu \
    --mode image \
    --build-dir=_build \
    --export qcow2 \
    local_container.mpp.yml \
    local_container.$arch.qcow2
fi

