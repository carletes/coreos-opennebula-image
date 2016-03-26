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

If you plan on using OpenNebula's
[EC2 interface](http://docs.opennebula.org/4.14/advanced_administration/public_cloud/ec2qcg.html),
the image should be tagged with the attribute `EC2_AMI` set to `YES`
(the `register` target does this for you).


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
  user data to configure your CoreOS instance.

The following template assumes a CoreOS image called `coreos-alpha`,
and two virtual networks called `public-net` and `private-net`, and
uses them to provide the disk and the two network interfaces of a
virtual machine:

	NAME = coreos-alpha
	MEMORY = 512
	CPU = 1
	HYPERVISOR = kvm
	OS = [
	  ARCH = x86_64,
	  BOOT = hd
	]
	DISK = [
	  DRIVER = qcow2,
	  IMAGE = coreos-alpha
	]
	NIC=[
	  NETWORK = public-net
	]
	NIC=[
	  NETWORK = private-net
	]
	GRAPHICS = [
	  TYPE = VNC,
	  LISTEN = 0.0.0.0
	]
	USER_INPUTS = [
	  USER_DATA = "M|text|User data for `cloud-config`"
	]
	CONTEXT = [
	  NETWORK = YES,
	  SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]",
	  USER_DATA = "$USER_DATA"
	]

If you plan on using OpenNebula's
[EC2 interface](http://docs.opennebula.org/4.14/advanced_administration/public_cloud/ec2qcg.html),
your template should follow instead these conventions:

* It must **not** use any image, since the disk will be provided by
  the AMI you choose when you create your instances.
* It must include the attribute `EC2_INSTANCE_TYPE` set to a valid AWS
  instance type. If you plan on using OpenNebula's `econe-*`
  command-line tools, ensure that name is recognised by the Ruby AWS
  modules they depend on.
* The first network interface will be used as CoreOS' public IPv4
  address.
* If there is a second network interface defined, it will be used as
  CoreOS' private IPv4 network.

The following template assumes you have two virtual networks called
`public-net` and `private-net`, and uses them to provide the two
network interfaces of a virtual machine:

	NAME = t1.micro
	EC2_INSTANCE_TYPE = t1.micro
	MEMORY = 512
	CPU = 1
	HYPERVISOR = kvm
	OS = [
	  ARCH = x86_64,
	  BOOT = hd
	]
	NIC=[
	  NETWORK = public-net
	]
	NIC=[
	  NETWORK = private-net
	]
	GRAPHICS = [
	  TYPE = VNC,
	  LISTEN = 0.0.0.0
	]
	CONTEXT = [
	  NETWORK = YES,
	  SSH_PUBLIC_KEY = "$USER[SSH_PUBLIC_KEY]"
	]

## Contributing

Just fork this repository and open a pull request.
