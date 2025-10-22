.PHONY: install

install: install-node install-python

install-node:
	npm ci

install-python:
	poetry install

deep-clean:
	find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +

check-licenses:
	echo "Not implemented"

lint: lint-githubactions lint-githubaction-scripts

lint-githubactions:
	actionlint

lint-githubaction-scripts:
	shellcheck .github/scripts/*.sh

test:
	echo "Not implemented"

build:
	echo "Not implemented"
