#!/bin/bash

# Adapted from http://tylerpower.io/post/packer-build-vmware-appliance-on-linux/

set -e
if [ ! -z "${DEBUG}" ]; then
  set -x
fi

DEPENDENCIES=("ovftool")
for dep in "${DEPENDENCIES[@]}"
do
  if ! [ -x "$(command -v ${dep})" ]; then
      echo "${dep} must be available."
      exit 1
  fi
done

if [[ -z "${PACKER_BUILD_NAME}" ]]; then
  echo "PACKER_BUILD_NAME folder must be specified"
  exit 1
fi

for ovf in "output-$PACKER_BUILD_NAME"/*.ovf; do
  name=$(basename "${ovf}" .ovf).ova
  ovftool --compress=9 -o "${ovf}" "${name}"
done

rm -rf "output-$PACKER_BUILD_NAME" &>/dev/null