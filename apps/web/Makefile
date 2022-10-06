.PHONY: build
build: pnpm
	pnpm build

.PHONY: test
test: pnpm
	echo "nothing to see here"

.PHONY: dev
dev: pnpm
	pnpm dev

.PHONY: pnpm
pnpm:
	pnpm install --filter=$(shell cat package.json | jq -r .name)...

.PHONY: ci
ci:
	$(shell git rev-parse --show-toplevel)/scripts/docker-build.sh