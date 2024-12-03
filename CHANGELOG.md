# ckan-docker-base


GitHub Releases [Change Log](https://github.com/ckan/ckan-docker-base/releases)

## Release v20241125

### Important Changes
There are two important changes to be aware of that relate to the CKAN extensions test workflows using GitHub Actions.

As announced in previous releases the CKAN images are now built using the Debian-based official Python images. The Alpine-based 2.9 and 2.10 images are no longer supported and won't receive updates going forward. These images are the ones most commonly used in tests. In order to use the supported images, change the following section in your .github/workflows/test.yml file:
```
    runs-on: ubuntu-latest
    container:
      image: ckan/ckan-dev:2.10
```
To one of the supported images, e.g.:
```
    runs-on: ubuntu-latest
    container:
      image: ckan/ckan-dev:2.10-py3.10
```
If you are using the matrix property to support multiple CKAN versions, you can use this syntax:
```
    strategy:
      matrix:
        include:
          - ckan-version: "2.11"
            ckan-image: "ckan/ckan-dev:2.11-py3.10"
          - ckan-version: "2.10"
            ckan-image: "ckan/ckan-dev:2.10-py3.10"
          - ckan-version: "2.9"
            ckan-image: "ckan/ckan-dev:2.9-py3.9"
      fail-fast: false

    name: CKAN ${{ matrix.ckan-version }}
    runs-on: ubuntu-latest
    container:
      image: ${{ matrix.ckan-image }}
    services:
      solr:
        image: ckan/ckan-solr:${{ matrix.ckan-version }}-solr9
      postgres:
        image: ckan/ckan-postgres-dev:${{ matrix.ckan-version }}
```
To strengthen the images security and follow good practices, the latest version of the images runs with a dedicated user rather than root. This is not supported in GitHub Actions so in order to avoid failures, users will need to add the following option:

```
    container:
      image: ckan/ckan-dev:2.11
      options: --user root
```
This commit includes both changes to the workflow file.

Changes in file/directory ownership also means that there is now a separate command to install locally mounted extensions when using the Docker Compose development setup:

```
docker compose -f docker-compose.dev.yml run -u root ckan-dev ./install_src.sh
```
### What's Changed
* Dev mode: install src dir with separate script by @wardi in [#84](https://github.com/ckan/ckan-docker-base/pull/84)
* Minimise all root-owned files/directories in the running CKAN container by @kowh-ai in [#80](https://github.com/ckan/ckan-docker-base/pull/80)
* Simplify repo by @amercader in [#85](https://github.com/ckan/ckan-docker-base/pull/92)
* Simplify repo: updates by @kowh-ai in [#90](https://github.com/ckan/ckan-docker-base/pull/90)
* Build and test actions by @amercader in [#89](https://github.com/ckan/ckan-docker-base/pull/89)
* Add actions to build and push images to Docker Hub by @amercader in [#73](https://github.com/ckan/ckan-docker-base/pull/73)
* Create an additional Docker image tag with the latest git tag by @amercader in [#92](https://github.com/ckan/ckan-docker-base/pull/92)
* Full Changelog: [v20241111...v20241125](https://github.com/ckan/ckan-docker-base/compare/v20241111...v20241125)

## Release v20241111

### What's Changed
* Updates to CKAN 2.11 and master images (remove supervisor and tidy up) by @kowh-ai in [#77](https://github.com/ckan/ckan-docker-base/pull/77)
* Consolidate use of CKAN_VERSION vs CKAN_TAG ([7f88928](https://github.com/ckan/ckan-docker-base/commit/7f88928d78d51c801e92c20f36105d20a761dd75))
* Update versions for 2.10.5 and 2.11.0 release ([8ea8056](https://github.com/ckan/ckan-docker-base/commit/8ea8056ea833c7ef34d7f25c979571fd87d9ab4a)])
* Remove gevent system packages ([ffa9b2a](https://github.com/ckan/ckan-docker-base/commit/ffa9b2a09f2a406bf38ca8afa2303bd04a51f8be))
* Update and pin ckanext-envvars ([dea7460](https://github.com/ckan/ckan-docker-base/commit/dea74608624495360ff8fdcb9593bd62cf99ad96))
* Quote ENV vars in 2.9 Dockerfile ([b0a27df](https://github.com/ckan/ckan-docker-base/commit/b0a27dfe94a7b7c33180706e6ab542ede86f520e))
* Full Changelog: [v20240701...v20241111](https://github.com/ckan/ckan-docker-base/compare/v20240701...v20241111)

## Release 20240701

* Going forward, the CKAN Docker images will use Debian-based [official Python images](https://hub.docker.com/_/python)
  rather than Alpine-based. The base image used currently is `python:3.10-slim-bookworm`. 
  CKAN 2.9 and 2.10 images are provided for both Alpine and Debian but starting from CKAN 2.11,
  only Debian-based images will be provided. Users are encouraged to migrate existing images
  to the the new Debian-based ones. See the table in the [README](https://github.com/ckan/ckan-docker-base/blob/main/README.md)
  file for detailed information on which tag to choose. ([#61](https://github.com/ckan/ckan-docker-base/pull/61))
* Add images for the upcoming CKAN 2.11 version ([#69](https://github.com/ckan/ckan-docker-base/pull/69))
* Listen to ipv6 addresses internally ([#67](https://github.com/ckan/ckan-docker-base/pull/67))
