# https://status.nixos.org
CHANNEL=25.11

# https://hub.docker.com/r/nixos/nix/tags
DOCKER_TAG=2.32.4

HOST_NAME=5AFEBA5E
HOST_ID=$(shell echo $(HOST_NAME) | tr '[:upper:]' '[:lower:]')

BUILD_SCRIPT_TEMPLATE_PATH=src/build.template.sh
CONFIG_TEMPLATE_FILE_PATH=src/$(HOST_NAME).template.nix

WORKDIR_PATH=workdir
SSH_HOST_KEY_TYPE=ed25519
SSH_HOST_KEY_FILE_NAME=ssh_host_$(SSH_HOST_KEY_TYPE)_key
SSH_HOST_KEY_PATH=$(WORKDIR_PATH)/$(SSH_HOST_KEY_FILE_NAME)

BUILD_SCRIPT_PATH=$(WORKDIR_PATH)/build.sh
CONFIG_PATH=$(WORKDIR_PATH)/$(HOST_NAME).nix
ISO_PATH=$(WORKDIR_PATH)/$(HOST_NAME).iso

.PHONY: iso
iso: \
	$(ISO_PATH) \
	#

$(WORKDIR_PATH):
	mkdir -p $@;

$(SSH_HOST_KEY_PATH): \
	| $(WORKDIR_PATH) \
	#
	ssh-keygen \
		-t $(SSH_HOST_KEY_TYPE) \
		-f $(SSH_HOST_KEY_PATH) \
		-N '' \
	;

$(SSH_HOST_KEY_PATH).pub: \
	$(SSH_HOST_KEY_PATH) \
	#

$(CONFIG_PATH): \
	$(CONFIG_TEMPLATE_FILE_PATH) \
	Makefile \
	| $(WORKDIR_PATH) \
	#
	SSH_PUBLIC_KEY="$(shell cat $(SSH_PUBLIC_KEY_FILEPATH))" \
	HOST_NAME="$(HOST_NAME)" \
	HOST_ID="$(HOST_ID)" \
	SSH_HOST_KEY_TYPE="$(SSH_HOST_KEY_TYPE)" \
	SSH_HOST_KEY_FILE_NAME="$(SSH_HOST_KEY_FILE_NAME)" \
		envsubst \
			'\
			$$SSH_PUBLIC_KEY\
			$$HOST_NAME\
			$$HOST_ID \
			$$SSH_HOST_KEY_TYPE\
			$$SSH_HOST_KEY_FILE_NAME\
			'\
			< $< \
			> $@ \
		;

$(BUILD_SCRIPT_PATH): \
	$(BUILD_SCRIPT_TEMPLATE_PATH) \
	Makefile \
	| $(WORKDIR_PATH) \
	#
	CHANNEL="${CHANNEL}" \
	CONFIG_PATH="/$(CONFIG_PATH)" \
	ISO_PATH="/$(ISO_PATH)" \
		envsubst \
			'\
			$$CHANNEL \
			$$CONFIG_PATH \
			$$ISO_PATH \
			'\
			< $< \
			> $@ \
	;

$(ISO_PATH): \
	$(SSH_HOST_KEY_PATH).pub \
	$(BUILD_SCRIPT_PATH) \
	$(CONFIG_PATH) \
	Makefile \
	| $(WORKDIR_PATH) \
	#
	docker \
		run \
			--interactive \
			--tty \
			--platform=linux/amd64 \
			--volume $(shell pwd)/$(WORKDIR_PATH):/$(WORKDIR_PATH) \
			--workdir /$(WORKDIR_PATH) \
			nixos/nix:$(DOCKER_TAG) \
				sh \
					build.sh \
	;

.PHONY: confirm
confirm: \
	#
	@diskutil \
		list \
			"$(DISK_PATH)" \
		;

	@CONFIRMATION_KEY="YES"; \
	echo "Type $$CONFIRMATION_KEY to continue:"; \
	read LINE; \
	if [ "$$LINE" != "$$CONFIRMATION_KEY" ]; then exit 1; fi

.PHONY: flash
flash: \
	confirm \
	#
	ls \
		-l \
			"$(ISO_PATH)" \
		;

	diskutil \
		unmountDisk \
			"$(DISK_PATH)" \
		;

	sudo \
		dd \
			if="$(ISO_PATH)" \
			of="$(DISK_PATH)" \
			status=progress \
			bs=4M \
		;

	sync;
	sleep 3;

.PHONY: clean
clean: \
	#
	rm -rf "$(WORKDIR_PATH)";
