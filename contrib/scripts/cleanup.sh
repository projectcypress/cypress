#!/bin/bash -eux

# Ubuntu 16.04 introduces a new feature that causes ethernet device names to
# no longer be consistent, which causes problems with exported vms.
# This works around the issue by turning the feature off.
echo -e 'network:\n  version: 2\n  renderer: networkd\n  ethernets:\n    all:\n      match:\n        name: e*\n      dhcp4: yes\n'  > /etc/netplan/01-netcfg.yaml

