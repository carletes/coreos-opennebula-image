#!/usr/bin/env bash

set -x

if [ -r /dev/kvm ] ; then
    accelerator="kvm"
    boot_wait="60s"
else
    accelerator="none"
    boot_wait="120s"
fi
headless="${HEADLESS:-false}"
remove_vagrant_key="${REMOVE_VAGRANT_KEY:-true}"

exec packer $1 \
     -var accelerator=$accelerator \
     -var boot_wait=$boot_wait \
     -var headless=$headless \
     -var coreos_channel=$COREOS_CHANNEL \
     -var coreos_version=$COREOS_VERSION \
     -var iso_checksum=$COREOS_MD5_CHECKSUM \
     -var remove_vagrant_key=$remove_vagrant_key \
     $2
