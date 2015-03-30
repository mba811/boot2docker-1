VERSION = $(shell docker -v | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
PROJECT_URL = https://github.com/boot2docker/boot2docker
ISO_URL = $(PROJECT_URL)/releases/download/v$(VERSION)/boot2docker.iso

.PHONY: all
all: boot2docker.box

boot2docker.box: boot2docker.iso packer.json vagrantfile.rb
	packer build packer.json

boot2docker.iso:
	curl -LO ${ISO_URL}

.PHONY: clean
clean:
	rm -f boot2docker.iso
	rm -f boot2docker.box
	rm -rf packer_cache/
