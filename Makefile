COREOS_CHANNEL = alpha
COREOS_VERSION = 1000.0.0
COREOS_MD5_CHECKSUM = 2207f09699ee37e79c32aae972432059
OPENNEBULA_DATASTORE = default

PACKER_IMAGE_DIR = builds/coreos-$(COREOS_CHANNEL)-$(COREOS_VERSION)-qemu
PACKER_IMAGE_NAME = coreos-$(COREOS_CHANNEL)-$(COREOS_VERSION)
PACKER_IMAGE = $(PACKER_IMAGE_DIR)/$(PACKER_IMAGE_NAME)
PACKER_IMAGE_BZ2 = $(PACKER_IMAGE).bz2
PACKER_IMAGE_COMPRESSION = false
PACKER_IMAGE_DEPS = \
	coreos.json \
	packer.sh \
	files/install.yml \
	oem/coreos-setup-environment \
	oem/opennebula-cloudinit \
	oem/opennebula-common \
	oem/opennebula-hostname \
	oem/opennebula-network \
	oem/opennebula-ssh-key \
	scripts/cleanup.sh \
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
	mv $(PACKER_IMAGE_DIR)/packer-qemu $(PACKER_IMAGE)
ifeq ($(PACKER_IMAGE_COMPRESSION), true)
	bzip2 -9vk $(PACKER_IMAGE)
endif
	echo "Image file $(PACKER_IMAGE) ready"

.PHONY: appliance register clean

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

appliance: $(PACKER_IMAGE)
	./generate-appliance-json.py \
	  --output appliance.json \
	  $(COREOS_CHANNEL) \
	  $(COREOS_VERSION) \
	  $(PACKER_IMAGE).bz2 \
	  $(IMAGE_URL)

clean:
	rm -rf builds
