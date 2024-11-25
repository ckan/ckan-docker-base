# Pre-configured CKAN Docker images

This is the Git repo of the official Docker images for [CKAN](https://github.com/ckan/ckan/).

The images will usually be used as a Docker Compose install in conjunction with other Docker images that make up the CKAN platform. The official CKAN Docker install is located here: [ckan-docker](https://github.com/ckan/ckan-docker)

The following CKAN versions are available in base or dev forms. They are distinguished from one another using different Docker image tags:

| CKAN Version | Type |  Base image | Docker tag | Notes |
| --- | --- | --- | --- | --- |
| **2.11.x** | **base image** | `python:3.10-slim-bookworm` | `ckan/ckan-base:2.11`, `ckan/ckan-base:2.11.0`, `ckan/ckan-base:2.11-py3.10`, `ckan/ckan-base:2.11.0-py3.10`          |  |
| **2.11.x** | **dev image**  | `python:3.10-slim-bookworm` | `ckan/ckan-dev:2.11`, `ckan/ckan-dev:2.11.0`, `ckan/ckan-dev:2.11-py3.10`, `ckan/ckan-dev:2.11.0-py3.10`            |  |
| 2.10.x | base image | `python:3.10-slim-bookworm` | `ckan/ckan-base:2.10-py3.10`, `ckan/ckan-base:2.10.5-py3.10` |  |
| 2.10.x | dev image  | `python:3.10-slim-bookworm` | `ckan/ckan-dev:2.10-py3.10`, `ckan/ckan-dev:2.10.5-py3.10`   |  |
| 2.10.x | base image | `alpine:3.17`               | `ckan/ckan-base:2.10.5`, `ckan/ckan-base:2.10`               | :warning: Deprecated. Please use a Python/Debian based image |
| 2.10.x | dev image  | `alpine:3.17`               | `ckan/ckan-dev:2.10.5`, `ckan/ckan-dev:2.10`                 | :warning: Deprecated. Please use a Python/Debian based image |
| 2.9.x  | base image | `python:3.9-slim-bookworm`  | `ckan/ckan-base:2.9-py3.9`, `ckan/ckan-base:2.9.11-py3.9`    |  |
| 2.9.x  | dev image  | `python:3.9-slim-bookworm`  | `ckan/ckan-dev:2.9-py3.9`, `ckan/ckan-dev:2.9.11-py3.9`      |  |
| 2.9.x  | base image | `alpine:3.15`               | `ckan/ckan-base:2.9.11`, `ckan/ckan-base:2.9`                | :warning: Deprecated. Please use a Python/Debian based image |
| 2.9.x  | dev image  | `alpine:3.15`               | `ckan/ckan-dev:2.9.11`, `ckan/ckan-dev:2.9`                  | :warning: Deprecated. Please use a Python/Debian based image |
| master | base image | `python:3.10-slim-bookworm` | `ckan/ckan-base:master`, `ckan/ckan-base:master-py3.10`      | Built daily, do not use in production |
| master | dev image  | `python:3.10-slim-bookworm` | `ckan/ckan-dev:master`, `ckan/ckan-dev:master-py3.10`        | Built daily, do not use in production |

In addition to the Docker tags listed above, there are additional ones published for each of these images [releases](https://github.com/ckan/ckan-docker-base/releases), in the form:

  ckan/ckan-base:{major_version}-py{python_version}-{release_name}


Older CKAN versions might be available as [image tags](https://hub.docker.com/r/ckan/ckan-base/tags) but note that these are not supported as per [CKAN's release policy](https://docs.ckan.org/en/latest/maintaining/releases.html#supported-versions).


### Repo structure

Each CKAN version is located in separate repo containing:

```
ckan-X.XX
├── Dockerfile          # Dockerfile for the image (in older versions there might be one for alpine and one for python)
├── VERSION.txt         # Full CKAN version built (eg. 2.11.0, 2.10.5)
├── PYTHON_VERSION.txt  # Python version used (eg. 3.10)
└── setup               # Setup scripts used by the images
    ├── prerun.py
    ├── start_ckan_development.sh
    ├── start_ckan.sh
    ├── unsafe.cert
    └── unsafe.key

```

### Release

Images are built and pushed to the Docker Hub after a new [release](https://github.com/ckan/ckan-docker-base/releases)
is published.
All non-trivial changes to this repo (certainly those which affect the images) should be
done via a Pull Request. This will trigger automated tests that check that the image
builds fine and perform some basic tests, but more thorough local testing might be necessary.

Once the maintainers decide it's time to do a new release, changes should be documented as
part of the release notes. Publishing the new release will trigger the actions that push
the images to Docker Hub.


### Building the images locally

The images can be built locally for development and debugging purposes

> [!WARNING]
> Do not push images directly to the Docker Hub locally. Use the proper release process described
> above.

All operations are done using the `build.sh` script located at the root of the repository.

```
Usage: ./build.sh <action> [<params>]
Available actions:
  versions                   - Shows the current CKAN versions used
  build <version> [base|dev] - Builds images for a CKAN version
                               Pass 'base' or 'dev' to just build these.
  push  <version>            - Pushes images to the Docker Hub

```

For instance:

```
./build.sh build 2.11

./build.sh build master
./build.sh build 2.10 base
./build.sh build 2.9 dev
```


