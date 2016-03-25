#!/bin/bash

# Put the OEM `cloud-config` dependent scripts in the right place.
sudo mkdir /usr/share/oem/bin
for f in cloudinit common network ssh-key ; do
    sudo mv ~/opennebula-$f /usr/share/oem/bin/
done
sudo mv ~/coreos-setup-environment /usr/share/oem/bin/
sudo chown -R root: /usr/share/oem/
sudo chmod -R 0755 /usr/share/oem/bin
