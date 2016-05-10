#!/usr/bin/env bash

# Remove SSH server keys from image.
# Keys will be regenerated on first boot => sshd-keygen.service
sudo rm -f /etc/ssh/ssh_host_*_key
sudo rm -f /etc/ssh/ssh_host_*_key.pub
