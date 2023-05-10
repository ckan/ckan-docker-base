.PHONY: all help build build-all push
SHELL := /bin/bash
CKAN_VERSION=ckan-2.9.8-dev
TAG_NAME="ckan/ckan-base:$(CKAN_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:	## Build a CKAN 2.9.8-dev image , `make build`
ifeq ($(CKAN_VERSION),$(filter $(CKAN_VERSION),ckan-2.9.8-dev))
	docker build -t $(TAG_NAME) .
endif

push: ## Push a CKAN 2.9.8-dev image to the DockerHub registry, `make push`
ifeq ($(CKAN_VERSION),$(filter $(CKAN_VERSION),ckan-2.9.8-dev))
	docker push $(TAG_NAME)
endif