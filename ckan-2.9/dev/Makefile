.PHONY: all help build build-all push
SHELL := /bin/bash
CKAN_VERSION=2.9.8-dev
TAG_NAME="ckan/ckan-base:$(CKAN_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:	## Build a CKAN 2.x-dev image , `make build`
	docker build --build-arg="CKAN_VERSION=ckan-$(CKAN_VERSION)" -t $(TAG_NAME) .

push: ## Push a CKAN 2.x-dev image to the DockerHub registry, `make push`
	docker push $(TAG_NAME)
