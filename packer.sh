#!/bin/bash

set -eux

coreos_download_url="http://${COREOS_CHANNEL}.release.core-os.net/amd64-usr/current"

# Fetch CoreOS signing keys.
gpg --recv-keys 50E0885593D2DCB4

# Get latest CoreOS version number.
curl -Ov ${coreos_download_url}/version.txt
curl -Ov ${coreos_download_url}/version.txt.DIGESTS.asc
gpg --verify version.txt.DIGESTS.asc
expected_md5=$(grep version.txt version.txt.DIGESTS.asc | head -n 1)
if [ "$(md5sum version.txt)" != "$expected_md5" ] ; then
    echo "Invalid MD5 checksum of `version.txt`"
    exit 1
fi
. ./version.txt
coreos_version=$COREOS_VERSION

# Get MD5 checksum of latest CoreOS ISO image.
curl -Ov ${coreos_download_url}/coreos_production_iso_image.iso.DIGESTS.asc
gpg --verify coreos_production_iso_image.iso.DIGESTS.asc
if [ "$?" = "1" ] ; then
    echo "Invalid GPG signature for coreos_production_iso_image.iso.DIGESTS.asc"
    exit 1
fi
coreos_md5_checksum=$(grep coreos_production_iso_image coreos_production_iso_image.iso.DIGESTS.asc | \
	      head -n 1 | \
	      awk '{print $1}')

if [ -r /dev/kvm ] ; then
    accelerator="kvm"
    boot_wait="60s"
else
    accelerator="none"
    boot_wait="120s"
fi
headless="${HEADLESS:-false}"

exec packer $1 \
     -var accelerator=$accelerator \
     -var boot_wait=$boot_wait \
     -var headless=$headless \
     -var coreos_channel=$COREOS_CHANNEL \
     -var coreos_version=$coreos_version \
     -var iso_checksum=$coreos_md5_checksum \
     $2
