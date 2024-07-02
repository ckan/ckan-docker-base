# ckan-docker-base

## Release 20240701

* Going forward, the CKAN Docker images will use Debian-based [official Python images](https://hub.docker.com/_/python)
  rather than Alpine-based. The base image used currently is `python:3.10-slim-bookworm`. 
  CKAN 2.9 and 2.10 images are provided for both Alpine and Debian but starting from CKAN 2.11,
  only Debian-based images will be provided. Users are encouraged to migrate existing images
  to the the new Debian-based ones. See the table in the [README](https://github.com/ckan/ckan-docker-base/blob/main/README.md)
  file for detailed information on which tag to choose. ([#61](https://github.com/ckan/ckan-docker-base/pull/61))
* Add images for the upcoming CKAN 2.11 version ([#69](https://github.com/ckan/ckan-docker-base/pull/69))
* Listen to ipv6 addresses internally ([#67](https://github.com/ckan/ckan-docker-base/pull/67))
