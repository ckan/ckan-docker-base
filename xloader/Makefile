.PHONY: all help build build-all push
SHELL := /bin/bash
CKAN_VERSION=2.10.4
XLOADER_VERSION=1.0.1
CKAN_VERSION_MAJOR=$(shell echo $(CKAN_VERSION) | cut -d'.' -f1)
CKAN_VERSION_MINOR=$(shell echo $(CKAN_VERSION) | cut -d'.' -f2)
TAG_NAME="ckan/ckan-base-xloader:$(XLOADER_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:	## Build CKAN XLoader images , `make build`
	echo "Building $(TAG_NAME) images"
	docker build --build-arg="CKAN_TAG=ckan-$(CKAN_VERSION)" --build-arg="XLOADER_TAG=$(XLOADER_VERSION)" -t $(TAG_NAME) --no-cache .

push: ## Push CKAN XLoader images to the DockerHub registry, `make push`
	echo "Pushing $(TAG_NAME) image"
	docker push $(TAG_NAME)