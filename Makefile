# Makefile for davedittrich.utils Ansible collection.
SHELL=/bin/bash
# The following are inter-related components that form a fragile whole that can
# easily break when one of the components is updated. This can randomly cause a
# frustratingly difficult situation to fix to pop up when you least expect it.
ANSIBLE_COMPONENTS=ansible ansible-core ansible-compat ansible-lint molecule-plugins pytest-testinfra pytest
ANSIBLE_COMMANDS=ansible ansible-lint molecule pytest python python3 pip pip3
export COLLECTION_NAMESPACE=davedittrich
DELEGATED_HOST:=none
export MOLECULE_DISTRO=debian12
MOLECULE_DESTROY=never
PLAYBOOK=playbooks/workstation_setup.yml
SCENARIO=default
USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)

# This project uses poetry for managing Python packages.
# Install poetry into conda environment.
export POETRY_HOME:=$(CONDA_PREFIX)
POETRY_INSTALL_URL=https://raw.githubusercontent.com/python-poetry/install.python-poetry.org/refs/heads/main/install-poetry.py
POETRY_VERSION=1.8.4

# The first rule in Makefile is implicitly the default rule, so make it explicit.
.PHONY: default
default: help

.PHONY: help
help:
	@echo "make [VARIABLE=value] target [target ...]"
	@echo "...where 'target' is one or more of:"
	@echo ""
	@echo "  build - build ansible-galaxy collection artifact"
	@echo "  clean - remove temporary and intermediate files"
	@echo "  check-conda - check 'conda' and 'psec' environment settings"
	@echo "  converge - molecule converge on scenario '$(SCENARIO)'"
	@echo "  destroy - destroy and clean up scenario '$(SCENARIO)'"
	@echo "  flash - flash SD card including latest build artifact"
	@echo "  flash-none - flash SD card without a build artifact"
	@echo "  lint - run linting tasks"
	@echo "  login - connect to '$(SCENARIO)' molecule instance for debugging"
	@echo "  publish - publish the artifact to Ansible galaxy (default $(ANSIBLE_GALAXY_SERVER))"
	@echo "  reset - clean up molecule scenario data"
	@echo "  retest - re-run molecule tests on scenario '$(SCENARIO)' on distro ($(MOLECULE_DISTRO)) without destroying"
	@echo "  scenario-exists - checks to ensure the scenario (variable 'SCENARIO') exists."
	@echo "  spotless - clean, then get rid of as much else as possible"
	@echo "  test - run molecule tests on scenario '$(SCENARIO)' on distro ($(MOLECULE_DISTRO)) after destroying"
	@echo "  test-all-distros - run molecule tests on all scenarios (fake 'matrix' like GitHub Actions)"
	@echo "  help-delegated-host - provide help on using the 'delegated' scenario"
	@echo "  test-delegated - run molecule against delegated host ($(DELEGATED_HOST))"
	@echo "  verify - run tests on scenario '$(SCENARIO)'"
	@echo "  version - show the current version number from 'VERSION' file"
	@echo "  update-packages - update Python packages using poetry"
	@echo ""
	@echo "Variables:"
	@echo "  ANSIBLE_GALAXY_SERVER ('$(ANSIBLE_GALAXY_SERVER)' from psec)"
	@echo "  ANSIBLE_GALAXY_API_KEY (see 'psec secrets show --no-redact')"
	@echo "  COLLECTION_NAMESPACE ('$(COLLECTION_NAMESPACE)')"
	@echo "  MOLECULE_DISTRO ('$(MOLECULE_DISTRO)')"
	@echo "  SCENARIO ('$(SCENARIO)')"
	@echo ""
	@echo "The variables 'ANSIBLE_GALAXY_SERVER' and 'ANSIBLE_GALAXY_API_KEY' come from"
	@echo "the default psec environment ($(shell psec environments default))".
	@echo ""
	@echo "Doing 'make test' will do 'molecule test --destroy=never' by default to help"
	@echo "debugging playbooks and verification tests. To change this (e.g., in the"
	@echo "continuous integration context) do 'make MOLECULE_DESTROY=always test' instead."
	@echo ""
	@echo "Setting variables on the 'make' command line will be propagated as environment"
	@echo "variables down into command run by 'make'. Look at the 'molecule/default/molecule.yml'"
	@echo "file to see how this is done. The 'Makefile' itself provides defaults (some shown"
	@echo "above) that allow you to control things like which scenario to use, etc. Setting"
	@echo "these as environment variables effectively changes the defaults for that shell,"
	@echo "which can make command lines shorter and thus easier to type (less typos!)"
	@echo ""
	@echo "Examples:"
	@echo " $$ make SCENARIO=branding test"

.PHONY: install-poetry
install-poetry:
	@if [[ "$(shell poetry --version 2>/dev/null)" =~ "$(POETRY_VERSION)" ]]; then \
		echo "[+] poetry version $(POETRY_VERSION) is already installed"; \
	else \
		(curl -sSL $(POETRY_INSTALL_URL) | python - --version $(POETRY_VERSION)); \
		poetry self add "poetry-dynamic-versioning[plugin]"; \
	fi

.PHONY: uninstall-poetry
uninstall-poetry:
	curl -sSL $(POETRY_INSTALL_URL) | python - --version $(POETRY_VERSION) --uninstall

#HELP update-packages - update dependencies with Poetry
.PHONY: update-packages
update-packages: install-poetry
	poetry update
	python -m pip uninstall -y pytest-ansible

.PHONY: check-conda
check-conda:
	@./scripts/check-conda.sh

galaxy.yml:
	@echo "[+] generating new 'galaxy.yml' file"
	ansible-playbook -i 'localhost,' build/galaxy_yml_create.yml

.PHONY: build
build: check-conda
	./scripts/build_artifact.sh

.PHONY: flash
flash:
	artifact=$(shell scripts/get_last_artifact.sh `pwd`) && \
	cd hypriot && \
	$(MAKE) COLLECTION_ARTIFACT=$$artifact flash

.PHONY: flash-none
flash-none:
	cd hypriot && $(MAKE) COLLECTION_ARTIFACT=None flash

.PHONY: clean
clean: clean-artifacts
	-rm -rf ~/.cache/ansible-compat ~/.cache/molecule ~/.cache/pip
	-rm -f pytestdebug.log
	find * -name '*.pyc' -delete 2>/dev/null || true
	find * -name __pycache__ -exec rmdir {} ';' 2>/dev/null || true

.PHONY: clean-artifacts
clean-artifacts:
	./scripts/clean_artifacts.sh || true

.PHONY: reset-molecule
reset-molecule:
	for scenario in default $(shell grep '[-] davedittrich.utils.' molecule/default/converge.yml | cut -d. -f 3); \
	do \
		molecule reset -s $$scenario > /dev/null; \
	done

.PHONY: clean-molecule
clean-molecule:
	for scenario in default $(shell grep '[-] davedittrich.utils.' molecule/default/converge.yml | cut -d. -f 3); \
	do \
		molecule destroy -s $$scenario > /dev/null; \
	done
	molecule list
	for image in $(shell docker images | grep molecule | awk '{ print $$3; }'); \
	do \
		echo docker rmi $$image; \
	done


.PHONY: converge
converge: check-conda scenario-exists galaxy.yml
	molecule converge -s $(SCENARIO)

.PHONY: destroy
destroy: check-conda scenario-exists galaxy.yml
	molecule destroy -s $(SCENARIO)

.PHONY: verify
verify: check-conda scenario-exists galaxy.yml
	molecule verify -s $(SCENARIO)

.PHONY: lint
lint: galaxy.yml
	make version
	make dependencies
	yamllint molecule/ playbooks/ plugins/ roles/ tasks/
	ruff check -v molecule/shared/tests playbooks/ plugins/ roles/ tasks/
	ansible-lint --project-dir . -c .ansible-lint molecule/shared/tests playbooks/ plugins/ roles/ tasks/

.PHONY: login
login: scenario-exists
	molecule login -s $(SCENARIO)

.PHONY: publish
publish: check-conda
	@if [[ "$(GITHUB_ACTIONS)" == "true" ]]; then \
		echo '[+] GitHub Actions workflows use GitHub Secrets'; \
		./scripts/publish_artifact.sh; \
	else \
		psec -E run -- ./scripts/publish_artifact.sh; \
	fi

.PHONY: reset
reset:
	molecule reset -s $(SCENARIO)

.PHONY: scenario-exists
scenario-exists:
	@if [[ ! -d molecule/$(SCENARIO) ]]; then \
		echo -n "[-] scenario '$(SCENARIO)' does not exist "; \
		echo "choose from: [$(shell cd molecule && echo */molecule.yml | cut -d/ -f1)]"; \
		exit 1; \
	fi

.PHONY: scenario-converged
scenario-converged:
	if [[ "$(shell molecule list -s $(SCENARIO) -f yaml 2>/dev/null | yq '.[0] | .Converged')" == "false" ]]; then \
		$(MAKE) converge; \
	fi

.PHONY: spotless
spotless: clean clean-molecule
	-rm -f davedittrich-utils-latest.tar.gz davedittrich-utils-[0-9]*[0-9].tar.gz

.PHONY: test-debug
test-debug: lint reset
	$(MAKE) SETVARIABLES=FORDEBUGGING retest

.PHONY: test
test: lint reset retest

.PHONY: test-no-lint
test-no-lint: reset retest

.PHONY: retest
retest: check-conda scenario-exists galaxy.yml
	@docker info 2>/dev/null | grep -q ID || (echo "[-] docker does not appear to be running" && exit 1)
	molecule test --destroy=$(MOLECULE_DESTROY) -s $(SCENARIO)
	@echo '[+] all tests succeeded'
	@if [[ "$(MOLECULE_DESTROY)" = "never" ]]; then \
		echo "[+] instance(s) were not destroyed: use 'molecule destroy' or 'molecule reset' manually"; \
	fi

.PHONY: test-all-distros
test-all-distros: scenario-exists galaxy.yml lint
	set -e; for distro in debian11 debian12 ubuntu2004 ubuntu2204; do MOLECULE_DISTRO=$$distro molecule test -s $(SCENARIO); done

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
	@echo davedittrich.utils version $(shell cat VERSION)
#	@for component in $(ANSIBLE_COMPONENTS); \
#	 do \
#	 $$component --version 2>/dev/null || \
#	 python -m pip freeze | grep "^$$component==" || \
#	 true; \
#	 done

# Use ANSIBLE_VERBOSITY to control whether to run `pipdeptree`.
.PHONY: dependencies
dependencies:
	pipdeptree -p $(shell sed 's/ /,/g' <<< "$(ANSIBLE_COMPONENTS)") || true
	for COMMAND in $(ANSIBLE_COMMANDS); do type $$COMMAND; $$COMMAND --version; done
	@#for PACKAGE in $(ANSIBLE_COMPONENTS); do pipdeptree -p $$PACKAGE; done

.PHONY: setup
setup: collection-community-docker

.PHONY: collection-community-docker
collection-community-docker:
	if ! ansible-galaxy collection list community.docker --format yaml | grep -q community.docker; \
	then \
		ansible-galaxy collection install community.docker; \
	fi

.PHONY: fix-broken-ansible
fix-broken-ansible:
	python -m pip uninstall -y $(ANSIBLE_COMPONENTS)
	$(MAKE) update-requirements

# EOF
