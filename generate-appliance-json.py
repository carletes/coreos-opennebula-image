#!/usr/bin/env python

"""Uploads a CoreOS image to the OpenNebula MarketPlace."""

import argparse
import hashlib
import json
import os
import sys


SHORT_DESCRIPTION_TEMPLATE = """
CoreOS %(channel)s image for KVM hosts under OpenNebula.
""".strip()

DESCRIPTION_TEMPLATE = """
Password for user `core` is disabled. You will need an SSH key in order to
log in.

This image works best with two network interfaces defined:

* The first network interface will be used as CoreOS' private IPv4
  address.
* If there is a second network interface defined, it will be used as
  CoreOS' public IPv4 network.

The VM template bundled with this image includes a `USER_DATA` field, with
which you may pass extra
[cloud-config](https://coreos.com/os/docs/latest/cloud-config.html)
user data to configure your CoreOS instance.

The source code for this image is available at:

  <https://github.com/carletes/coreos-opennebula-image>

Contributions are most welcome!
""".strip()

IMAGE_TEMPLATE_TEXT = json.dumps({
    "CONTEXT": {
        "NETWORK": "YES",
        "SET_HOSTNAME": "$NAME",
        "SSH_PUBLIC_KEY": "$USER[SSH_PUBLIC_KEY]",
        "USER_DATA": "$USER_DATA",
    },
    "CPU": "1",
    "GRAPHICS": {
        "LISTEN": "0.0.0.0",
        "TYPE": "vnc"
    },
    "MEMORY": "512",
    "OS": {
        "ARCH": "x86_64"
    },
    "USER_INPUTS": {
        "USER_DATA": "M|text|User data for `cloud-config`",
    }
})


def main():
    p = argparse.ArgumentParser(description=__doc__.strip())
    p.add_argument("channel",
                   help="CoreOS channel of the image")
    p.add_argument("version",
                   help="CoreOS version of the image")
    p.add_argument("image",
                   help="path to the qcow2 image file to upload")
    p.add_argument("--output",
                   help=("path to the outpu JSON file. If not given, the "
                         "image will not be uploaded."))

    args = p.parse_args()
    vars = {
        "channel": args.channel,
        "version": args.version,
    }

    hypervisor = "KVM"
    image_fmt = "qcow2"
    os_arch = "x86_64"
    os_id = "CoreOS"
    os_release = "%s (%s channel)" % (args.version, args.channel)
    appliance = json.dumps({
        "name": "CoreOS %s" % (args.channel,),
        "short_description": SHORT_DESCRIPTION_TEMPLATE % vars,
        "description": DESCRIPTION_TEMPLATE % vars,
        "version": args.version,
        "opennebula_version": "4.14",
        "files": [
            {
                "name": "coreos-%s-%s" % (args.channel, args.version),
                "size": str(os.stat(args.image).st_size),
                "md5": md5_hash(args.image),
                "compression": "none",
                "driver": image_fmt,
                "type": "OS",
                "hypervisor": hypervisor,
                "format": image_fmt,
                "os-id": os_id,
                "os-release": os_release,
                "os-arch": os_arch
            }
        ],
        "hypervisor": hypervisor,
        "format": image_fmt,
        "os-id": os_id,
        "os-release": os_release,
        "os-arch": os_arch,
        "opennebula_template": IMAGE_TEMPLATE_TEXT,
    }, indent=4)

    if args.output is None:
        print appliance
        return

    with open(args.output, "w") as f:
        f.write(appliance)


def md5_hash(fname):
    md5 = hashlib.md5()
    with open(fname, "rb") as f:
        md5.update(f.read())
    return md5.hexdigest()



if __name__ == "__main__":
    sys.exit(main())
