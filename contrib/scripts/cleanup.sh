#!/bin/bash -eux

# Ubuntu 16.04 introduces a new feature that causes ethernet device names to
# no longer be consistent, which causes problems with exported vms.
# This works around the issue by turning the feature off.
echo 'GRUB_CMDLINE_LINUX="biosdevname=0 net.ifnames=0"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo 'auto eth0' >> /etc/network/interfaces
echo 'iface eth0 inet dhcp' >> /etc/network/interfaces
echo 'auto eth1' >> /etc/network/interfaces
echo 'iface eth1 inet manual' >> /etc/network/interfaces