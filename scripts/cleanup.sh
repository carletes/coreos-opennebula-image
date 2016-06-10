#!/usr/bin/env bash

# Remove SSH server keys from image.
# Keys will be regenerated on first boot => sshd-keygen.service
sudo rm -f /etc/ssh/ssh_host_*_key
sudo rm -f /etc/ssh/ssh_host_*_key.pub

if [ "$REMOVE_VAGRANT_KEY" = "true" ] || [ "$REMOVE_VAGRANT_KEY" = "1" ]; then
    # Remove packer public key.
    # update-ssh-keys won't update the authorized_keys if no key under authorized_keys.d were found.
    # Truncate authorized_keys instead.
    sudo update-ssh-keys -u core -d oem-provisioner || sudo truncate -s0 $(getent passwd 'core' | cut -d: -f6)/.ssh/authorized_keys
fi
