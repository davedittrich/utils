COLLECTION_NAMESPACE=davedittrich
SHELL=/bin/bash

.PHONY: build
build:
	ansible-playbook -vvv ../playbooks/build_test_images.yml
	$(MAKE) list-images

.PHONY: list-images
list-images:
	docker images | egrep "ID|geerlingguy/docker-.*-ansible|$(COLLECTION_NAMESPACE)/docker-.*-ansible"

.PHONY: clean 
clean:
	for image in $(shell docker images \
		       --format "{{.ID}} {{.Repository}}" | \
		       egrep "geerlingguy/docker-.*-ansible|$(COLLECTION_NAMESPACE)/docker-.*-ansible" | \
		       awk '{ print $$1; }'); do \
		docker rmi $$image; \
	done
	rm -f build-docker-*-ansible.log
