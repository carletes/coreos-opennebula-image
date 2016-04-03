#!/bin/bash

# Remove SSH server keys from image.

sudo rm -f /etc/ssh/ssh_host_*_key
sudo rm -f /etc/ssh/ssh_host_*_key.pub
