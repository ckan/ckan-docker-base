.PHONY: all help build build-all push
SHELL := /bin/bash
DATAPUSHER_VERSION=0.0.18
TAG_NAME="ckan/ckan-base-datapusher:$(DATAPUSHER_VERSION)"

all: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:	## Build a DataPusher 0.0.18 image , `make build`
ifeq ($(DATAPUSHER_VERSION),$(filter $(DATAPUSHER_VERSION),0.0.18))
	docker build -t $(TAG_NAME) .
endif

push: ## Push a DataPusher 0.0.18 image to the DockerHub registry, `make push`
ifeq ($(DATAPUSHER_VERSION),$(filter $(DATAPUSHER_VERSION),0.0.18))
	docker push $(TAG_NAME)
endif