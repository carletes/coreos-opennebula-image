# CoreOS image for OpenNebula

This repository contains a [Packer](https://www.packer.io) template
for creating [CoreOS](https://coreos.com) KVM images for
[OpenNebula](http://opennebula.org).

Based on [@bfraser](https://github.com/bfraser)'s
[packer-coreos-qemu](https://github.com/bfraser/packer-coreos-qemu).


## Building the OpenNebula image

You will need:

* [Packer](https://www.packer.io) (tested with version 0.10.0)
* [QEMU](http://wiki.qemu.org/Main_Page) (tested with version 2.0.0)
* [GNU Make](https://www.gnu.org/software/make/)

A Linux host with KVM support will make the build much faster.

The build process is driven with `make`:

    $ make
	[..]
	Image file builds/coreos-alpha-991.0.0-qemu/packer-qemu ready
	$

By default, `make` will build a CoreOS image from the
[CoreOS alpha channel](https://coreos.com/releases/). You may specify
a particular CoreOS version and channel by passing the appropriate
parameters to `make`:

    $ make COREOS_CHANNEL=stable COREOS_VERSION=899.13.0 COREOS_MD5_CHECKSUM=31f1756ecdf5bca92a8bff355417598f
	[..]
	Image file builds/coreos-stable-899.13.0-qemu/packer-qemu ready
	$


## Registering the image with OpenNebula

Once the image has been built, you may upload it to OpenNebula using
the
[Sunstone UI](http://docs.opennebula.org/4.14/user/virtual_resource_management/img_guide.html#id1).

Alternatively, if you are allowed to access OpenNebula using its
[command-line tools](http://docs.opennebula.org/4.14/user/references/cli.html#id1),
you may upload the image usng `make`:

    $ make register

The `register` target also accepts specific CoreOS channels and
versions:

    $ make register COREOS_CHANNEL=stable COREOS_VERSION=899.13.0 COREOS_MD5_CHECKSUM=31f1756ecdf5bca92a8bff355417598f


## Creating an OpenNebula VM template

Before creating CoreOS VMs, you will need to create an
[OpenNebula VM template](http://docs.opennebula.org/4.14/user/virtual_resource_management/vm_guide.html#creating-virtual-machines)
which uses the CoreOS images you have built. The VM template should
follow these conventions:

* It should use the image you have created and uploaded.
* The first network interface will be used as CoreOS' public IPv4
  address.
* If there is a second network interface defined, it will be used as
  CoreOS' private IPv4 network.
* You should add a user input field called `USER_DATA`, so that you
  may pass extra
  [cloud-config](https://coreos.com/os/docs/latest/cloud-config.html)
  user data to configure yur CoreOS instance.

For example:

	$ onetemplate show -x coreos-alpha
	<VMTEMPLATE>
	  <ID>7</ID>
	  <UID>2</UID>
	  <GID>0</GID>
	  <UNAME>carlos</UNAME>
	  <GNAME>oneadmin</GNAME>
	  <NAME>coreos-alpha</NAME>
	  <PERMISSIONS>
		<OWNER_U>1</OWNER_U>
		<OWNER_M>1</OWNER_M>
		<OWNER_A>0</OWNER_A>
		<GROUP_U>0</GROUP_U>
		<GROUP_M>0</GROUP_M>
		<GROUP_A>0</GROUP_A>
		<OTHER_U>0</OTHER_U>
		<OTHER_M>0</OTHER_M>
		<OTHER_A>0</OTHER_A>
	  </PERMISSIONS>
	  <REGTIME>1458841514</REGTIME>
	  <TEMPLATE>
		<CONTEXT>
		  <NETWORK><![CDATA[YES]]></NETWORK>
		  <SSH_PUBLIC_KEY><![CDATA[$USER[SSH_PUBLIC_KEY]]]></SSH_PUBLIC_KEY>
		  <USER_DATA><![CDATA[$USER_DATA]]></USER_DATA>
		</CONTEXT>
		<CPU><![CDATA[1]]></CPU>
		<DISK>
		  <DRIVER><![CDATA[qcow2]]></DRIVER>
		  <IMAGE><![CDATA[coreos-alpha]]></IMAGE>
		  <IMAGE_UNAME><![CDATA[carlos]]></IMAGE_UNAME>
		</DISK>
		<GRAPHICS>
		  <LISTEN><![CDATA[0.0.0.0]]></LISTEN>
		  <TYPE><![CDATA[VNC]]></TYPE>
		</GRAPHICS>
		<HYPERVISOR><![CDATA[kvm]]></HYPERVISOR>
		<MEMORY><![CDATA[512]]></MEMORY>
		<NIC>
		  <NETWORK><![CDATA[public-net]]></NETWORK>
		  <NETWORK_UNAME><![CDATA[carlos]]></NETWORK_UNAME>
		</NIC>
		<NIC>
		  <NETWORK><![CDATA[private-net]]></NETWORK>
		  <NETWORK_UNAME><![CDATA[carlos]]></NETWORK_UNAME>
		</NIC>
		<OS>
		  <ARCH><![CDATA[x86_64]]></ARCH>
		</OS>
		<USER_INPUTS>
		  <USER_DATA><![CDATA[M|text|User data for `cloud-init`]]></USER_DATA>
		</USER_INPUTS>
	  </TEMPLATE>
	</VMTEMPLATE>


## Contributing

Just fork this repository and open a pull request.
