SHELL=/bin/bash

.PHONY: help
help:
	@echo "make [VARIABLE=value] target [target ...]"
	@echo "...where 'target' is one or more of:"
	@echo "  lint - run 'molecule lint'"

.PHONY: lint
lint:
	yamllint .
	ansible-lint .

