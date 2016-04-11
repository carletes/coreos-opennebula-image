COREOS_CHANNEL = alpha
OPENNEBULA_DATASTORE = default

PACKER_IMAGE_DIR = builds/coreos-$(COREOS_CHANNEL)-qemu
PACKER_IMAGE_NAME = coreos-$(COREOS_CHANNEL)
PACKER_IMAGE = $(PACKER_IMAGE_DIR)/$(PACKER_IMAGE_NAME)
PACKER_IMAGE_BZ2 = $(PACKER_IMAGE).bz2
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
	  PACKER_LOG=1 \
	    ./packer.sh validate coreos.json
	env \
	  COREOS_CHANNEL=$(COREOS_CHANNEL) \
	  PACKER_LOG=1 \
	    ./packer.sh build coreos.json
	mv $(PACKER_IMAGE_DIR)/packer-qemu $(PACKER_IMAGE)
	bzip2 -9vk $(PACKER_IMAGE)
	echo "Image file $(PACKER_IMAGE) ready"

.PHONY: appliance register clean

OPENNEBULA_IMAGE = coreos-$(COREOS_CHANNEL)

register: $(PACKER_IMAGE)
	-oneimage delete $(OPENNEBULA_IMAGE)
	oneimage create \
	  --name $(OPENNEBULA_IMAGE) \
	  --description "CoreOS $(COREOS_CHANNEL)" \
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
	  $(PACKER_IMAGE).bz2 \
	  $(IMAGE_URL)

clean:
	rm -rf builds
