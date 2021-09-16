ANSIBLE_GALAXY_SERVER:=$(shell psec secrets get ansible_galaxy_server)
ANSIBLE_GALAXY_API_KEY:=$(shell psec secrets get ansible_galaxy_api_key)
ARTIFACT=davedittrich-utils-$(VERSION).tar.gz
export COLLECTION_NAMESPACE=davedittrich
COLLECTION_PATH="$(HOME)/.ansible/collections.dev:$(HOME)/.ansible/collections"
DELEGATED_HOST:=none
export MOLECULE_DISTRO=debian10
export MOLECULE_REPO=davedittrich
PLAYBOOK=playbooks/workstation-setup.yml
SCENARIO:=default
SHELL=/bin/bash
VERSION=$(shell grep "version:" galaxy.yml | sed 's/ //g' | cut -d: -f 2)

.PHONY: help
help:
	@echo "make [VARIABLE=value] target [target ...]"
	@echo "...where 'target' is one or more of:"
	@echo "  build - build the ansible-galaxy collection"
	@echo "  build-images - build Docker images from geerlingguy images"
	@echo "	                with extra packages installed already"
	@echo "  clean - remove temporary and intermediate files"
	@echo "  clean-images - remove Docker images"
	@echo "  converge - molecule converge on scenario"
	@echo "  login - connect to molecule instance for debugging"
	@echo "  publish - publish the artifact to Ansible galaxy (default $(ANSIBLE_GALAXY_SERVER))"
	@echo "  scenario-exists - checks to ensure the scenario (variable 'SCENARIO') exists."
	@echo "  spotless - clean, then get rid of as much else as possible"
	@echo "  test - run molecule tests on scenario on default distro ($(MOLECULE_DISTRO))"
	@echo "  test-all-distros - run molecule tests on all scenarios (fake 'matrix' like GitHub Actions)"
	@echo "  test-delegated - run molecule against delegated host ($(DELEGATED_HOST))"
	@echo "  version - show the current version number from 'galaxy.yml' file"
	@echo ""
	@echo "Variables:"
	@echo "  ANSIBLE_GALAXY_SERVER ('$(ANSIBLE_GALAXY_SERVER)' from psec)"
	@echo "  ANSIBLE_GALAXY_API_KEY (see 'psec secrets show --no-redact')"
	@echo "  ARTIFACT ('$(ARTIFACT)')"
	@echo "  COLLECTION_NAMESPACE ('$(COLLECTION_NAMESPACE)')"
	@echo "  MOLECULE_DISTRO ('$(MOLECULE_DISTRO)')"
	@echo "  MOLECULE_REPO ('$(MOLECULE_REPO)')"
	@echo "  SCENARIO ('$(SCENARIO)')"
	@echo "  VERSION ('$(VERSION)')"
	@echo ""
	@echo "The variables 'ANSIBLE_GALAXY_SERVER' and 'ANSIBLE_GALAXY_API_KEY' come from"
	@echo "the default psec environment ($(shell psec environments default))".
	@echo ""
	@echo "Setting variables on the 'make' command line will be propagated as environment"
	@echo "variables down into command run by 'make'. Look at the 'molecule/default/molecule.yml'"
	@echo "file to see how this is done. The 'Makefile' itself provides defaults (some shown"
	@echo "above) that allow you to control things like which scenario to use, etc. Setting"
	@echo "these as environment variables effectively changes the defaults for that shell,"
	@echo "which can make command lines shorter and thus easier to type (less typos!)"
	@echo ""
	@echo "Examples:"
	@echo " $$ make DISTRO=ubuntu2004 test"
	@echo " $$ make MOLECULE_REPO=davedittrich SCENARIO=branding test"

.PHONY: build
build:
	ansible-galaxy collection build -vvvv
	@tar -tzf $(ARTIFACT) | grep -v '.*/$$' | while read line; do echo ' -->' $$line; done

.PHONY: build-images
build-images:
	cd docker && $(MAKE) build

.PHONY: clean
clean:
	rm davedittrich-utils-*.tar.gz
	find * -name '*.pyc' -delete
	find * -name __pycache__ -exec rmdir {} ';' || true

.PHONY: clean-images
clean-images:
	cd docker && $(MAKE) spotless

.PHONY: converge
converge: scenario-exists
	molecule converge -s $(SCENARIO)

.PHONY: login
login: scenario-exists
	molecule login -s $(SCENARIO)

.PHONY: publish
publish: $(ARTIFACT)
	@if [[ ! -f $(ARTIFACT) ]]; then \
		echo "[-] artifact '$(ARTIFACT)' does not exist. Try one of these:"; \
		ls davedittrich-utils-*.tar.gz; \
		exit 1; \
	fi
	ansible-galaxy collection publish \
		$(ARTIFACT) \
		--server=$(ANSIBLE_GALAXY_SERVER) \
		--api-key=$(ANSIBLE_GALAXY_API_KEY)


.PHONY: scenario-exists
scenario-exists:
	@if [[ ! -d molecule/$(SCENARIO) ]]; then \
		echo -n "[-] scenario '$(SCENARIO)' does not exist "; \
		echo "choose from: [$(shell cd molecule && find * -depth 1 -name molecule.yml | cut -d/ -f1)]"; \
		exit 1; \
	fi

.PHONY: spotless
spotless: clean clean-images

.PHONY: test
test: scenario-exists
	molecule test -s $(SCENARIO)

.PHONY: test-all-distros
test-all-distros: scenario-exists
	set -e; for distro in debian9 debian10 ubuntu1804 ubuntu2004; do MOLECULE_DISTRO=$$distro molecule test -s $(SCENARIO); done

# For information (such that it is) on using the `delgated` driver to test
# against a remote host, see the following:
# https://molecule.readthedocs.io/en/latest/configuration.html#delegated
#
# Ensure that you have a file `delegated-ssh-config` with settings for
# the host you want to target for delgated testing, something like this:
#
# Host delegated-host
#     Hostname 192.168.0.1
#     IdentityFile /path/to/ssh-private-key
#     Port 22
#     User ansible-user

.PHONY: test-delegated
test-delegated:
#	@if [[ "$(DELEGATED_HOST)" == "none" ]]; then \
#		echo -n "[-] no target specified: "; \
#		echo "use 'make DELEGATED_HOST=IP-OR-NAME test-delegated"; \
#		exit 1; \
#	fi
	@if [[ ! -f delegated-ssh-config ]]; then \
		echo -n "[-] no SSH configuration `delegated-ssh-config` found"; \
		exit 1; \
	fi
	molecule test -s delegated
	# ansible-playbook -i "$(DELEGATED_HOST)," $(PLAYBOOK)

.PHONY: version
version:
	@echo version $(VERSION)
