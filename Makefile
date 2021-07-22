SHELL=/bin/bash
SCENARIO:=default
ANSIBLE_GALAXY_SERVER:=$(shell psec secrets get ansible_galaxy_server)
ANSIBLE_GALAXY_API_KEY:=$(shell psec secrets get ansible_galaxy_api_key)
VERSION=$(shell grep "version:" galaxy.yml | sed 's/ //g' | cut -d: -f 2)
ARTIFACT=davedittrich-utils-$(VERSION).tar.gz

.PHONY: build
build:
	ansible-galaxy collection build -vvvv
	@tar -tzf $(ARTIFACT) | grep -v '.*/$$' | while read line; do echo ' -->' $$line; done

.PHONY: clean
clean:
	rm davedittrich-utils-*.tar.gz
	find * -name '*.pyc' -delete
	find * -name __pycache__ -exec rmdir {} ';' || true

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

.PHONY: test
test: scenario-exists
	molecule test -s $(SCENARIO)

.PHONY: version
version:
	@echo version $(VERSION)
