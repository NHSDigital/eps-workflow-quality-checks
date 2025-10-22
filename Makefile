.PHONY: install

install: install-node

install-node:
	npm ci

deep-clean:
	find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +

check-license:
	echo "Not implemented"

lint:
	actionlint

test:
	echo "Not implemented"

build:
	echo "Not implemented"