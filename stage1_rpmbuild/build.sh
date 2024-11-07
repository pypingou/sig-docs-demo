#!/usr/bin/sh

image=true
while [[ $# -gt 0 ]]; do
  case $1 in
    --noimage)
      image=false
      shift # past argument
      ;;
  esac
done


if [ ! -d "sample-apps" ]; then
  git clone https://gitlab.com/CentOS/automotive/src/sample-apps.git
  pushd sample-apps
  git archive HEAD . --prefix=auto-apps-0.1/ --output=auto-apps-0.1.tar.gz
  cp auto-apps-0.1.tar.gz ../
  popd
fi


rpmbuild --define '%_topdir %{getenv:PWD}' \
    --define '%_sourcedir     %{_topdir}' \
    --define '%_specdir       %{_topdir}' \
    --define '%_srcrpmdir     %{_topdir}' \
    --define '%_builddir	  %{_topdir}' \
    --define '%_buildrootdir  %{_topdir}' \
    --define '%_rpmdir   	  %{_topdir}' \
    -ba auto-apps.spec

arch=$(arch)
mkdir -p /var/tmp/my_repo
cp -rp ./$arch/* /var/tmp/my_repo/
createrepo /var/tmp/my_repo

if [ $image = true ]; then
  source /etc/os-release

  sid="autosd"
  if [ $ID == "fedora" ]; then
    sid="f"
  fi

  automotive-image-builder --verbose --container \
    --include=/var/tmp/my_repo \
    build \
    --distro $sid$VERSION_ID \
    --target qemu \
    --mode image \
    --build-dir=_build \
    --export qcow2 \
    rpmbuild.mpp.yml \
    rpmbuild-image.$arch.qcow2
fi
