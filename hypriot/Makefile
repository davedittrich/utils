# This Makefile uses `python-secrets` (`psec`) to manage insertion
# of secrets into a cloud-config file maintained outside of this
# source code repository. This minimizes the possibility of accidental
# commit+push of a file including secrets. It also has `make` targets
# enabling downloading and validation of the HypriotOS image to be
# used.  For more information, see:
#
#   https://github.com/davedittrich/python_secrets

# NOTE: Use simple variables (`:=`) when necessary to avoid recursive
# expansion problems when one variable references another variable (e.g.,
# `HYPRIOT_VERSION`) as part of its definition.

SHELL=/bin/bash
# Try to use a temporary directory outside of the repo directory to avoid
# accidental Git commits that leak secrets (e.g., CLOUD_CONFIG below).
export TMPDIR:=$(shell psec environments path --tmpdir 2>/dev/null || mktemp)
HYPRIOT_VERSION:=1.12.3
# HYPRIOT_VERSION:=$(shell curl -s https://api.github.com/repos/hypriot/image-builder-rpi/releases/latest | grep tag_name | cut -d\" -f4)
HYPRIOT_IMG:=hypriotos-rpi-v$(HYPRIOT_VERSION).img
HYPRIOT_ZIP:=$(HYPRIOT_IMG).zip
HYPRIOT_ZIP_URL:=https://github.com/hypriot/image-builder-rpi/releases/download/v$(HYPRIOT_VERSION)/$(HYPRIOT_ZIP)
HYPRIOT_SHA256_URL:=$(HYPRIOT_ZIP_URL).sha256
HYPRIOT_SHA256:=$(HYPRIOT_ZIP).sha256
HYPRIOT_HOSTNAME:=$(shell psec secrets get hypriot_hostname 2>/dev/null || echo hypriot)
CLOUD_CONFIG_SRC:=cloud-config.j2
CLOUD_CONFIG:=$(TMPDIR)/cloud-config
IMAGE=$(HYPRIOT_IMG)
ANSIBLE_COLLECTION:=$(shell bash ../scripts/get_last_artifact.sh ..)
# # Export `DEFAULT_ENV` or run `make DEFAULT_ENV=myenv ...` to override this default.
# DEFAULT_ENV:=flash
export FLASH=$(shell command -v flash)

.PHONY: all
all: help

.PHONY: help
help:
	@echo 'usage: make [VAR=val] TARGET [TARGET...]'
	@echo ''
	@echo 'TARGETS:'
	@echo '  autoconfigure - ensure initial configuration is automatically applied'
	@echo '  reconfigure - [NOT DONE YET]'
	@echo '  cloud-config - generate cloud-config file from template "$(CLOUD_CONFIG_SRC)"'
	@echo '  flash - flash $(HYPRIOT_IMG) to SD card with user-data $(CLOUD_CONFIG)'
	@echo '  hypriot-img - download $(HYPRIOT_ZIP) file, check SHA256 sum, unzip'
	@echo ''
	@echo 'DEVELOPMENT/DEBUGGING TARGETS:'
	@echo '  clean - remove temporary files'
	@echo '  spotless - clean, then remove HypriotOS image files'
	@echo '  variables - show variables'
	@echo ''
	@echo "To generate new secrets, run 'psec secrets generate'"
	@echo "To set undefined string secrets, run 'psec secrets set --undefined'"
	@echo "To use an alternate cloud-init template, run 'make CLOUD_CONFIG_SRC=template.j2 flash'"
	@echo "To flash from images that you are customizing locally with Hypriot's"
	@echo '`image-builder-rpi`, set the environment variable `HYPRIOT_IMG` with the path'
	@echo "to the built image:"
	@echo "  $$ export HYPRIOT_IMG='../image-builder-rpi/hypriotos-rpi-dirty.img'"
	@echo "or"
	@echo "  $$ make HYPRIOT_IMG='../image-builder-rpi/hypriotos-rpi-dirty.img' flash"
	@echo ""

.PHONY: cloud-config
cloud-config: $(CLOUD_CONFIG)

$(CLOUD_CONFIG): $(CLOUD_CONFIG_SRC)
	@[ -d $(TMPDIR) ] || (echo "TMPDIR does not point to a valid directory" && exit 1)
	psec template $< $@

.PHONY: hypriot-zip
hypriot-zip $(HYPRIOT_ZIP):
	wget -nc $(HYPRIOT_ZIP_URL)
	wget -nc $(HYPRIOT_SHA256_URL)
	sha256sum -c $(HYPRIOT_SHA256)

hypriotos-rpi-$(HYPRIOT_VERSION).img: $(HYPRIOT_ZIP)
	unzip $(HYPRIOT_ZIP)
	ls -l $(HYPRIOT_IMG)

# When developing custom disk images with Hypriot's `image-builder-rpi`,
# the image name will include "dirty" and there is nothing to do to
# create the image. If you are pulling a versioned image in a .zip file,
# then it is necessary to possibly download and extract the image. This
# is done in a subordinate make shell.

.PHONY: hypriot-img
hypriot-img: hypriotos-rpi-$(HYPRIOT_VERSION).img
	@if grep -q 'dirty' <<< "$(HYPRIOT_IMG)" ; then \
		ls -l $(HYPRIOT_IMG); \
	else \
		$(MAKE) $(HYPRIOT_IMG) $(HYPRIOT_ZIP); \
	fi

.PHONY: reconfigure
reconfigure: autoconfigure
	@echo "[+] reconfigure ... [NOT DONE YET]"

.PHONY: autoconfigure
autoconfigure:
	@if [[ "$(shell psec environments default)" != "$(DEFAULT_ENV)" ]]; then \
		echo "[+] running 'psec environments default --set $(DEFAULT_ENV)'"; \
		psec environments default --set "$(DEFAULT_ENV)"; \
	 else \
		echo "[+] using psec environment '$(DEFAULT_ENV)' as the default environment"; \
	 fi
	@if ! psec environments path --exists; then \
		echo "[+] running 'psec environments create --clone-from hypriot.json'"; \
		echo psec environments create --clone-from hypriot.json; \
		echo "[+] running 'psec secrets generate --from-options'"; \
		echo psec secrets generate --from-options; \
	 fi
	@if ! psec -q secrets get hypriot_user >/dev/null; then \
		echo "[+] running 'psec secrets generate --from-options'"; \
		psec secrets generate --from-options; \
	 fi
	@if psec -q secrets get hypriot_client_ssid | grep -q None; then \
		echo "[+] Please set the following for WiFi access:"; \
		psec secrets set hypriot_client_ssid hypriot_client_psk hypriot_pubkey; \
	 fi

.PHONY: flash
flash: remove-key
	$(MAKE) --always-make cloud-config
	@[ -f $(HYPRIOT_IMG) ] || (echo "[-] set HYPRIOT_IMG with path to OS image or 'make hypriot-img'" && exit 1)
	bash ../scripts/flash-hypriot.sh $(IMAGE) $(CLOUD_CONFIG) $(shell bash ../scripts/get_last_artifact.sh ..) bootstrap.sh
	@echo "[+] Reminder: log in to host $(HYPRIOT_HOSTNAME) with user name '$(shell psec secrets get hypriot_user)' with password '$(shell psec secrets get hypriot_password)'"

.PHONY: setup
setup: hypriot-img
	psec environments create --clone-from hypriot.json
	psec secrets generate --from-options

.PHONY: clean
clean:
	[ ! -f "$(CLOUD_CONFIG)" ] || rm "$(CLOUD_CONFIG)"
	[ ! -f "$(HYPRIOT_IMG)" ] || rm "$(HYPRIOT_IMG)"

.PHONY: remove-key
remove-key:
	-ssh-keygen -R $(shell psec secrets get hypriot_hostname)

.PHONY: clean
spotless: clean
	[ ! -f "$(HYPRIOT_ZIP)" ] || rm "$(HYPRIOT_ZIP)"
	[ ! -f "$(HYPRIOT_SHA256)" ] || rm "$(HYPRIOT_SHA256)"

.PHONY: variables
variables: Makefile
	@echo CLOUD_CONFIG="$(CLOUD_CONFIG)"
	@echo CLOUD_CONFIG_SRC="$(CLOUD_CONFIG_SRC)"
	@echo HYPRIOT_HOSTNAME="$(HYPRIOT_HOSTNAME)"
	@echo HYPRIOT_IMG="$(HYPRIOT_IMG)"
	@echo HYPRIOT_SHA256="$(HYPRIOT_SHA256)"
	@echo HYPRIOT_VERSION="$(HYPRIOT_VERSION)"
	@echo HYPRIOT_ZIP="$(HYPRIOT_ZIP)"
	@echo TMPDIR="$(TMPDIR)"
	@echo ANSIBLE_COLLECTION="$(ANSIBLE_COLLECTION)"

.PHONY: debug-server
debug-server:
	tar -cf - gosecure_app.py forms.py templates/ scripts/ | ssh gosecure sudo tar -C goSecure_Web_GUI/ -xvf -
	ssh gosecure sudo service gosecure restart
