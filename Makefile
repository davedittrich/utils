SHELL=/bin/bash

PHONY: clean
clean:
	find * -name '*.pyc' -delete
	find * -name __pycache__ -exec rmdir {} ';' || true
