.PHONY: all help build build-all push
SHELL := /bin/bash
CKAN_VERSION=2.10.4
UBUNTU_VERSION=22.04
DEBIAN_VERSION=12
UBUNTU.DOCKERFILE=Dockerfile.ubuntu.$(UBUNTU_VERSION)
DEBIAN.DOCKERFILE=Dockerfile.debian.$(DEBIAN_VERSION)
CKAN_VERSION_MAJOR=$(shell echo $(CKAN_VERSION) | cut -d'.' -f1)
CKAN_VERSION_MINOR=$(shell echo $(CKAN_VERSION) | cut -d'.' -f2)
TAG_NAME="ckan/ckan-base:$(CKAN_VERSION)"
ALT_TAG_NAME="ckan/ckan-base:$(CKAN_VERSION_MAJOR).$(CKAN_VERSION_MINOR)"
UBUNTU_TAG_NAME="ckan/ckan-base:$(CKAN_VERSION).ubuntu.$(UBUNTU_VERSION)"
UBUNTU_ALT_TAG_NAME="ckan/ckan-base:$(CKAN_VERSION).ubuntu.$(UBUNTU_VERSION)"
DEBIAN_TAG_NAME="ckan/ckan-base:$(CKAN_VERSION).debian.$(DEBIAN_VERSION)"
DEBIAN_ALT_TAG_NAME="ckan/ckan-base:$(CKAN_VERSION).debian.$(DEBIAN_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:	## Build a CKAN 2.x.x image , `make build`
	echo "Building $(TAG_NAME) and $(ALT_TAG_NAME) images"
	#docker build --build-arg="CKAN_VERSION=ckan-$(CKAN_VERSION)" -t $(TAG_NAME) -t $(ALT_TAG_NAME) .
	#docker build --build-arg="CKAN_VERSION=ckan-$(CKAN_VERSION)" -t $(UBUNTU_TAG_NAME) -t $(UBUNTU_ALT_TAG_NAME) -f $(UBUNTU.DOCKERFILE) --no-cache .
	docker build --build-arg="CKAN_VERSION=ckan-$(CKAN_VERSION)" -t $(DEBIAN_TAG_NAME) -t $(DEBIAN_ALT_TAG_NAME) -f $(DEBIAN.DOCKERFILE) --no-cache .

push: ## Push a CKAN 2.x.x image to the DockerHub registry, `make push`
	#echo "Pushing $(TAG_NAME) image"
	#docker push $(TAG_NAME)
	#echo "Pushing $(ALT_TAG_NAME) image"
	#docker push $(ALT_TAG_NAME)
