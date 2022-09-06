ANSIBLE_GALAXY_SERVER:=$(shell psec secrets get ansible_galaxy_server 2>/dev/null)
ANSIBLE_GALAXY_API_KEY:=$(shell psec secrets get ansible_galaxy_api_key 2>/dev/null)
# The following are inter-related components that form a fragile whole that can
# easily break when one of the components is updated. This can randomly cause a
# frustratingly difficult situation to fix to pop up when you least expect it.
ANSIBLE_COMPONENTS=ansible ansible-core ansible-compat ansible-lint molecule molecule-testinfra molecule-docker pytest-ansible pytest-testinfra pytest testinfra
export COLLECTION_NAMESPACE=davedittrich
DELEGATED_HOST:=none
export MOLECULE_DISTRO=debian11
export MOLECULE_REPO=davedittrich
PLAYBOOK=playbooks/workstation_setup.yml
PYTHON_EXE:=$(CONDA_PREFIX)/bin/python3
PYTHONPATH=$(shell pwd)/molecule
SCENARIO=default
SHELL=/bin/bash
USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)
VERSION=$(shell cat VERSION)
ARTIFACT=davedittrich-utils-$(VERSION).tar.gz

.PHONY: help
help:
	@echo "make [VARIABLE=value] target [target ...]"
	@echo "...where 'target' is one or more of:"
	@echo "  build - build version v$(VERSION) of the ansible-galaxy collection"
	@echo "  build-images - build Docker images from geerlingguy images"
	@echo "	                with extra packages already installed"
	@echo "  collection-dev-link - create collections development directory link pointing to repo directory"
	@echo "  clean - remove temporary and intermediate files"
	@echo "  clean-images - remove Docker images"
	@echo "  converge - molecule converge on scenario '$(SCENARIO)'"
	@echo "  destroy - destroy and clean up scenario '$(SCENARIO)'"
	@echo "  lint - run 'molecule lint'"
	@echo "  login - connect to '$(SCENARIO)' molecule instance for debugging"
	@echo "  publish - publish the artifact to Ansible galaxy (default $(ANSIBLE_GALAXY_SERVER))"
	@echo "  scenario-exists - checks to ensure the scenario (variable 'SCENARIO') exists."
	@echo "  spotless - clean, then get rid of as much else as possible"
	@echo "  test - run molecule tests on scenario '$(SCENARIO)' on distro ($(MOLECULE_DISTRO))"
	@echo "  test-all-distros - run molecule tests on all scenarios (fake 'matrix' like GitHub Actions)"
	@echo "  help-delegated-host - provide help on using the 'delegated' scenario"
	@echo "  test-delegated - run molecule against delegated host ($(DELEGATED_HOST))"
	@echo "  verify - run tests on scenario '$(SCENARIO)'"
	@echo "  version - show the current version number from 'VERSION' file"
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

galaxy.yml:
	ansible-playbook -i 'localhost,' -e 'galaxy_yml_only=true' build/galaxy_deploy.yml

.PHONY: build
build:
	ansible-playbook -vvvv -i 'localhost,' build/galaxy_deploy.yml
	@tar -tzf $(ARTIFACT) | grep -v '.*/$$' | while read line; do echo ' -->' $$line; done

.PHONY: build-images
build-images:
	-molecule destroy
	-docker kill instance
	-docker rm instance
	ansible-playbook -i docker/hosts.yml \
		-e '{ \
		"ansible_python_interpreter": "$(PYTHON_EXE)", \
		"target_distros": ["debian11"], \
		"docker_user": "$(USER_ID)", \
		"docker_group": "$(GROUP_ID)" \
		}' -vvv playbooks/build_test_images.yml
	$(MAKE) list-images

.PHONY: list-images
list-images:
	docker images | egrep "ID|geerlingguy/docker-.*-ansible|$(COLLECTION_NAMESPACE)/docker-.*-ansible"

.PHONY: clean-images
clean-images:
	for image in $(shell docker images \
		       --format "{{.ID}} {{.Repository}}" | \
		       egrep "geerlingguy/docker-.*-ansible|$(COLLECTION_NAMESPACE)/docker-.*-ansible" | \
		       awk '{ print $$1; }'); do \
		docker rmi $$image; \
	done
	rm -f build-docker-*-ansible.log

.PHONY: clean-collection
clean-collection:
	@for D in $(shell echo ~/.cache/ansible-compat/*/collections/ansible_collections/*); \
	do \
		if [ -f $$D/utils/README.md ]; \
		then \
			echo "[+] cleaning $$D"; \
			rm -rf $$D; \
		fi; \
	done || true

.PHONY: clean
clean: clean-collection
	-rm -f davedittrich-utils-*.tar.gz || true
	@echo '[+] 1'
	find * -name '*.pyc' -delete
	@echo '[+] 2'
	find * -name __pycache__ -exec rmdir {} ';' || true
	@echo '[+] 3'

.PHONY: clean-molecule
clean-molecule:
	molecule destroy --all
	for scenario in default $(shell grep '[-] davedittrich.utils.' molecule/default/converge.yml | cut -d. -f 3); \
	do \
		molecule reset -s $$scenario > /dev/null; \
	done

.PHONY: converge
converge: scenario-exists galaxy.yml
	molecule converge -s $(SCENARIO)

.PHONY: destroy
destroy: scenario-exists galaxy.yml
	molecule destroy -s $(SCENARIO)

.PHONY: verify
verify: scenario-exists galaxy.yml
	molecule verify -s $(SCENARIO)

.PHONY: lint
lint: galaxy.yml
	molecule lint

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
		echo "choose from: [$(shell cd molecule && echo */molecule.yml | cut -d/ -f1)]"; \
		exit 1; \
	fi

.PHONY: spotless
spotless: clean clean-images

.PHONY: test
test: scenario-exists clean-collection galaxy.yml
	docker info 2>/dev/null | grep -q ID || (echo "[-] docker does not appear to be running" && exit 1)
	molecule test -s $(SCENARIO)
	@echo '[+] all tests succeeded'

.PHONY: test-all-distros
test-all-distros: scenario-exists galaxy.yml
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
test-delegated: galaxy.yml
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
	@echo davedittrich.utils version $(VERSION)
	@for component in $(ANSIBLE_COMPONENTS); \
	 do \
	 $$component --version 2>/dev/null || \
	 python3 -m pip freeze | grep "^$$component==" || \
	 true; \
	 done

.PHONY: dependencies
dependencies:
	pipdeptree -p $(shell sed 's/ /,/g' <<< "$(ANSIBLE_COMPONENTS)")

.PHONY: setup
setup: collection-community-docker

.PHONY: create-collections-dev-link
create-collections-dev-link:
	@bash scripts/create-collections-dev-link

.PHONY: collection-community-docker
collection-community-docker:
	if ! ansible-galaxy collection list community.docker --format yaml | grep -q community.docker; \
	then \
		ansible-galaxy collection install community.docker; \
	fi

.PHONY: fix-broken-ansible
fix-broken-ansible:
	# .tox/lint/bin/python3 -m pip uninstall -y $(ANSIBLE_COMPONENTS)
	python3 -m pip uninstall -y $(ANSIBLE_COMPONENTS)
	python3 -m pip install -U -r requirements.txt

# EOF
