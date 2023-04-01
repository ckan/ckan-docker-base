.PHONY: all help build build-all push
SHELL := /bin/bash
DATAPUSHER_VERSION=0.0.20
TAG_NAME="ckan/ckan-base-datapusher:$(DATAPUSHER_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build a DataPusher image
	echo "Building DataPusher image for version $(DATAPUSHER_VERSION)"
	docker build -t $(TAG_NAME) --build-arg DATAPUSHER_VERSION=$(DATAPUSHER_VERSION) .

push: ## Push a DataPusher image to the Docker Hub registry
	docker push $(TAG_NAME)
