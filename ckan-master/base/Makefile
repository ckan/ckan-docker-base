.PHONY: all help build build-all push
SHELL := /bin/bash
COMMIT_HASH=c555a97
CKAN_VERSION=master-${COMMIT_HASH}
TAG_NAME="ckan/ckan-base:$(CKAN_VERSION)-$(COMMIT_HASH)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:	## Build a CKAN master image , `make build`
ifeq ($(CKAN_VERSION),$(filter $(CKAN_VERSION),master-c555a97))
	docker build -t $(TAG_NAME) .
endif

push: ## Push a CKAN master image to the DockerHub registry, `make push`
ifeq ($(CKAN_VERSION),$(filter $(CKAN_VERSION),master-c555a97))
	docker push $(TAG_NAME)
endif