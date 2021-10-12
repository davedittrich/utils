ANSIBLE_GALAXY_SERVER:=$(shell psec secrets get ansible_galaxy_server)
ANSIBLE_GALAXY_API_KEY:=$(shell psec secrets get ansible_galaxy_api_key)
ARTIFACT=davedittrich-utils-$(VERSION).tar.gz
export COLLECTION_NAMESPACE=davedittrich
COLLECTION_PATH="$(HOME)/.ansible/collections.dev:$(HOME)/.ansible/collections"
DELEGATED_HOST:=none
export MOLECULE_DISTRO=debian10
export MOLECULE_REPO=davedittrich
PLAYBOOK=playbooks/workstation-setup.yml
PYTHONPATH=$(shell pwd)/molecule
SCENARIO:=default
SHELL=/bin/bash
VERSION=$(shell grep "version:" galaxy.yml | sed 's/ //g' | cut -d: -f 2)

.PHONY: help
help:
	@echo "make [VARIABLE=value] target [target ...]"
	@echo "...where 'target' is one or more of:"
	@echo "  build - build version v$(VERSION) of the ansible-galaxy collection"
	@echo "  build-images - build Docker images from geerlingguy images"
	@echo "	                with extra packages already installed"
	@echo "  clean - remove temporary and intermediate files"
	@echo "  clean-images - remove Docker images"
	@echo "  converge - molecule converge on scenario '$(SCENARIO)'"
	@echo "  destroy - destroy and clean up scenario '$(SCENARIO)'"
	@echo "  login - connect to '$(SCENARIO)' molecule instance for debugging"
	@echo "  publish - publish the artifact to Ansible galaxy (default $(ANSIBLE_GALAXY_SERVER))"
	@echo "  scenario-exists - checks to ensure the scenario (variable 'SCENARIO') exists."
	@echo "  spotless - clean, then get rid of as much else as possible"
	@echo "  test - run molecule tests on scenario '$(SCENARIO)' on distro ($(MOLECULE_DISTRO))"
	@echo "  test-all-distros - run molecule tests on all scenarios (fake 'matrix' like GitHub Actions)"
	@echo "  test-delegated - run molecule against delegated host ($(DELEGATED_HOST))"
	@echo "  verify - run tests on scenario '$(SCENARIO)'"
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

.PHONY: destroy
destroy: scenario-exists
	molecule destroy -s $(SCENARIO)

.PHONY: verify
verify: scenario-exists
	molecule verify -s $(SCENARIO)

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
	@echo '[+] all tests succeeded'

.PHONY: test-all-distros
test-all-distros: scenario-exists
	set -e; for distro in debian9 debian10 ubuntu1804 ubuntu2004; do MOLECULE_DISTRO=$$distro molecule test -s $(SCENARIO); done

.PHONY: help-delegated-host
help-delegated-host:
	@echo "For information (such that it is) on using the `delegated` driver to test"
	@echo "against a remote host, see the following:"
	@echo "  https://molecule.readthedocs.io/en/latest/configuration.html#delegated"
	@echo ""
	@echo "Ensure that you have a file named './delegated-ssh-config' with settings for"
	@echo "the host you want to target for delegated testing, something like this:"
	@echo ""
	@echo "  Host 192.168.0.1 myhost delegated-host"
	@echo "      Hostname 192.168.0.1"
	@echo "      IdentityFile /path/to/ssh-private-key"
	@echo "      Port 22"
	@echo "      User ansible-user"

.PHONY: test-delegated
test-delegated:
	@if [[ ! -f delegated-ssh-config ]]; then \
		echo -n "[-] no SSH configuration `delegated-ssh-config` found"; \
		exit 1; \
	fi
	@if ! grep -q 'delegated-host' delegated-ssh-config; then \
		echo "[-] no host labelled 'delegated-host' in the ./delegated-ssh-config file"; \
		$(MAKE) help-delegated-host; \
		exit 1; \
	fi
	molecule test -s delegated

.PHONY: version
version:
	@echo version $(VERSION)
