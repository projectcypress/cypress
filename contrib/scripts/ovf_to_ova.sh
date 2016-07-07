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

if [[ -z $1 ]]; then
  echo "First parameter must be a path to an OVF file."
  exit 1
fi

if [[ $1 =~ \.ovf$ ]]; then
  name=$(basename "${1}" .ovf).ova
  ovftool --compress=9 -o "${1}" "${name}"
fi