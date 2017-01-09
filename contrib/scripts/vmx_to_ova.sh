#!/bin/bash

# Adapted from http://tylerpower.io/post/packer-build-vmware-appliance-on-linux/

set -e
if [ ! -z "${DEBUG}" ]; then
  set -x
fi

DEPENDENCIES=("ovftool")
for dep in "${DEPENDENCIES[@]}"; do
  if ! [ -x "$(command -v ${dep})" ]; then
      echo "${dep} must be available."
      exit 1
  fi
done

if [[ -z $PACKER_BUILD_NAME ]]; then
  echo "Environment Variable 'PACKER_BUILD_NAME' must be set."
  exit 1
fi

for vmx in "output-${PACKER_BUILD_NAME}"/*.vmx; do
  name=$(basename "${vmx}" .vmx).ova
  ovftool --compress=9 -o "${vmx}" "output-${PACKER_BUILD_NAME}/${name}"
done

# Cleanup all files that are not the ova
find "output-${PACKER_BUILD_NAME}" -type f ! -name '*.ova' -delete
