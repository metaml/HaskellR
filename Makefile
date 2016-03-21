.PHONY: dev build buildc buildv clean clobber bin

.DEFAULT_GOAL := help
SHELL := /bin/bash
PATH := bin:${HOME}/.local/bin:${PATH}
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

test: ## run tests and bench
	stack build --test --haddock --bench

jupyter: ## run jupyter
	stack exec ihaskell -- install
	stack exec jupyter -- notebook

clean: ## clean
	stack clean

clobber: ## clean and clobber stack env.
clobber: clean
	rm -rf .stack-work

bin:; ln -fs .stack-work/install/x86_64-linux/${LTS}/${GHCVER}/bin

init: ## install ubuntu packages
init: gld jupyter
	sudo apt-get update -y
	for i in libzmq3-dev r-base r-base-core r-base-dev; do \
		sudo apt-get install -y $$i; \
	done

install-ihaskell: build-ihaskell install-jupyter

IHASKELL = ihaskel
IHASKELL += ihaskell-aeson
IHASKELL += ihaskell-blaze
IHASKELL += ihaskell-charts
IHASKELL += ihaskell-diagrams
IHASKELL += ihaskell-rlangqq
IHASKELL += ihaskell-magic
IHASKELL += ihaskell-juicypixels
IHASKELL += ihaskell-hatex
IHASKELL += ihaskell-basic
build-ihaskell: ## install ihaskell
	for i in ${IHASKELL}; do stack build $$i; done

install-jupyter: ## install jupyter
install-jupyter: install-python
	pip3 install -U jupyter

install-python: ## install python3 pip3
	sudo apt-get install -y build-essential python3-dev python3-pip

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
