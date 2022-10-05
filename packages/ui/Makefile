.PHONY: build
build: pnpm
	echo "nothing to see here"

.PHONY: test
test: pnpm
	pnpm test

.PHONY: pnpm
pnpm:
	pnpm install --filter=$(shell cat package.json | jq -r .name)...

.PHONY: ci
ci:
	echo "TODO: Dockerize"