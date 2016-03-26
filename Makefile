COREOS_CHANNEL = alpha
COREOS_VERSION = 991.0.0
COREOS_MD5_CHECKSUM = 45cc5c753ecc959aa6ed62b6c683c7d3
OPENNEBULA_DATASTORE = default

PACKER_IMAGE_DIR = builds/coreos-$(COREOS_CHANNEL)-$(COREOS_VERSION)-qemu
PACKER_IMAGE = $(PACKER_IMAGE_DIR)/packer-qemu
PACKER_IMAGE_DEPS = \
	coreos.json \
	packer.sh \
	files/install.yml \
	oem/coreos-setup-environment \
	oem/opennebula-cloudinit \
	oem/opennebula-common \
	oem/opennebula-network \
	oem/opennebula-ssh-key \
	scripts/oem.sh

all: $(PACKER_IMAGE)

$(PACKER_IMAGE): $(PACKER_IMAGE_DEPS)
	rm -rf $(PACKER_IMAGE_DIR)
	env \
	  COREOS_CHANNEL=$(COREOS_CHANNEL) \
	  COREOS_VERSION=$(COREOS_VERSION) \
	  COREOS_MD5_CHECKSUM=$(COREOS_MD5_CHECKSUM) \
	  PACKER_LOG=1 \
	    ./packer.sh validate coreos.json
	env \
	  COREOS_CHANNEL=$(COREOS_CHANNEL) \
	  COREOS_VERSION=$(COREOS_VERSION) \
	  COREOS_MD5_CHECKSUM=$(COREOS_MD5_CHECKSUM) \
	  PACKER_LOG=1 \
	    ./packer.sh build coreos.json
	echo "Image file $(PACKER_IMAGE) ready"

.PHONY: register clean

OPENNEBULA_IMAGE = coreos-$(COREOS_CHANNEL)

register: $(PACKER_IMAGE)
	-oneimage delete $(OPENNEBULA_IMAGE)
	oneimage create \
	  --name $(OPENNEBULA_IMAGE) \
	  --description "CoreOS $(COREOS_CHANNEL) (version $(COREOS_VERSION))" \
	  --type OS \
	  --driver qcow2 \
	  --datastore $(OPENNEBULA_DATASTORE) \
	  --path $(PACKER_IMAGE)
	echo "EC2_AMI=YES" > .ec2_attrs
	oneimage update $(OPENNEBULA_IMAGE) --append .ec2_attrs
	rm -f .ec2_attrs

clean:
	rm -rf builds
