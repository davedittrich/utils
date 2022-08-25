SHELL=/bin/bash
USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)
export COLLECTION_NAMESPACE=davedittrich
PYTHON_EXE:=$(CONDA_PREFIX)/bin/python

# By default, only build the debian10 image to save time and space.
.PHONY: build
build: build-default

.PHONY: build-default
build-default:
	@echo PYTHON_EXE=$(PYTHON_EXE)
	ansible-playbook -e '{ \
		"ansible_python_interpreter": $(PYTHON_EXE), \
		"target_distros": ["debian10"], \
		"docker_user": $(USER_ID), \
		"docker_group": $(GROUP_ID) \
		}' -vvv ../playbooks/build_test_images.yml
	$(MAKE) list-images

.PHONY: build-all
build-all:
	ansible-playbook -e '{ \
		"ansible_python_interpreter": $(PYTHON_EXE), \
		"docker_user": $(USER_ID), \
		"docker_group": $(GROUP_ID) \
		}' -vvv ../playbooks/build_test_images.yml
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
