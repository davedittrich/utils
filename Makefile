SHELL=/bin/bash
SCENARIO:=default

.PHONY: clean
clean:
	find * -name '*.pyc' -delete
	find * -name __pycache__ -exec rmdir {} ';' || true

.PHONY: converge
converge:
	molecule converge -s $(SCENARIO)

.PHONY: login
login:
	molecule login -s $(SCENARIO)

.PHONY: test
test:
	molecule test -s $(SCENARIO)
