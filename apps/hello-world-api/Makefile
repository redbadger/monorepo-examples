.PHONY: build
build: 
	cargo build --release

.PHONY: test
test: 
	cargo test

.PHONY: ci
ci:
	$(shell git rev-parse --show-toplevel)/scripts/docker-build.sh