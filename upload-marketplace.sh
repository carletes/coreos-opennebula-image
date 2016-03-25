#!/bin/bash

set -u

image_name="$1"
image_size="$(wc -c $image_name | awk '{print $1}')"
image_md5="$(md5sum $image_name | awk '{print $1}')"

cat > /tmp/appliance.json <<EOF
{
  "name": "CoreOS $COREOS_CHANNEL",
  "short_description": "CoreOS $COREOS_CHANNEL (version $COREOS_VERSION)",
  "version": "$COREOS_VERSION",
  "hypervisor": "KVM",
  "files": [
    "name": "$image_name",
    "size": "$image_size",
    "md5": "$image_md5",
    "compression": "none",
    "type": "OS",
    "hypervisor": "KVM",
    "format": "raw",
    "os-arch": "x86_64",
    "driver": "qcow2"
  ],
  "opennebula_versions": "4.14"
}
EOF
