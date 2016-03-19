.PHONY: dev build buildc buildv clean clobber bin

.DEFAULT_GOAL := help
SHELL := /bin/bash
PATH := bin:${PATH}
LTS = $(shell egrep '^resolver:' stack.yaml | awk '{print $$2}')
GHCVER := $(shell stack ghc -- --numeric-version)

bbdev: clean buildc

# stack
build: ## build
build: bin
	stack build

buildv: ## build verbosely
buildv: bin
	stack build --verbose

buildc: ## build continuously
buildc: bin
	stack build --file-watch

clean: ## clean
	stack clean

clobber: ## clean and clobber stack env.
clobber: clean
	rm -rf .stack-work

bin:; ln -fs .stack-work/install/x86_64-linux/${LTS}/${GHCVER}/bin

init: ## install ubuntu packages
init: gld
	sudo apt-get update -y
	for i in libzmq3-dev r-base r-base-core r-base-dev; do \
		sudo apt-get install -y $$i; \
	done

gld: ## use gold linker
	sudo update-alternatives --install /usr/bin/ld ld /usr/bin/ld.gold 20
	sudo update-alternatives --install /usr/bin/ld ld /usr/bin/ld.bfd 10
	sudo update-alternatives --config ld

info:
	@echo "GHC VER: ${GHCVER}"
	@echo "LTS VER: ${LTS}"

help: ## help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
         | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'
