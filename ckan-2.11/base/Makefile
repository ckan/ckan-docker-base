.PHONY: all help build build-all push
SHELL := /bin/bash
# TODO: switch to tag upon release
CKAN_VERSION=dev-v2.11
PYTHON_VERSION=3.10
# TODO: major minor version
TAG_NAME="ckan/ckan-base:2.11"
PYTHON_TAG_NAME="ckan/ckan-base:2.11-py$(PYTHON_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build a CKAN 2.11 image , `make build`
	echo "Building $(TAG_NAME) images"
	docker build --build-arg="CKAN_VERSION=$(CKAN_VERSION)" -t $(TAG_NAME) -t $(PYTHON_TAG_NAME) .

push: ## Push a CKAN 2.11 image to the DockerHub registry, `make push`
	echo "Pushing $(TAG_NAME) image"
	docker push $(TAG_NAME)
	docker push $(PYTHON_TAG_NAME)
