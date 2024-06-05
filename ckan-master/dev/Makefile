.PHONY: all help build build-all push
SHELL := /bin/bash
CKAN_VERSION=master
PYTHON_VERSION=3.10
PYTHON.DOCKERFILE=Dockerfile.py-$(PYTHON_VERSION)
TAG_NAME="ckan/ckan-dev:$(CKAN_VERSION)"
PYTHON_TAG_NAME="ckan/ckan-dev:$(CKAN_VERSION).py-$(PYTHON_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build a CKAN master dev image , `make build`
	echo "Building $(TAG_NAME) and $(ALT_TAG_NAME) images"
	docker build --build-arg="CKAN_VERSION=$(CKAN_VERSION)" -t $(TAG_NAME) .
	docker build --build-arg="CKAN_TAG=$(CKAN_VERSION)" -t $(PYTHON_TAG_NAME) -f $(PYTHON.DOCKERFILE) .

push: ## Push a CKAN master dev image to the DockerHub registry, `make push`
	echo "Pushing $(TAG_NAME) image"
	docker push $(TAG_NAME)
	echo "Pushing $(PYTHON_TAG_NAME) image"
	docker push $(PYTHON_TAG_NAME)