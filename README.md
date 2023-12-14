# Pre-configured CKAN Docker images

This is the Git repo of the official Docker images for [CKAN](https://github.com/ckan/ckan/).

The images will usually be used as a Docker Compose install in conjunction with other Docker images that make up the CKAN platform. 

The official CKAN Docker install is located here: [ckan-docker](https://github.com/ckan/ckan-docker)

The following CKAN versions are available in base or dev forms. They are distinguished from one another using different Docker image tags:

| CKAN Version | Type | Docker tag | Notes |
| --- | --- | --- | --- |
| 2.9.10 | base image | `ckan/ckan-base:2.9.10` |  |
| 2.9.10 | dev image | `ckan/ckan-dev:2.9.10` |  |
| 2.10.3 | base image | `ckan/ckan-base:2.10.3` |  |
| 2.10.3 | dev image | `ckan/ckan-dev:2.10.3` |  |

Older CKAN versions might be available as [image tags](https://hub.docker.com/r/ckan/ckan-base/tags) but note that these are not supported as per [CKAN's release policy](https://docs.ckan.org/en/latest/maintaining/releases.html#supported-versions).


### Building and Pushing the images

The images can be built locally and tagged appropriately so they can then be pushed into the CKAN DockerHub repo
assuming you have the correct permission to do so

For CKAN 2.9.10 base images, go to the `ckan-2.9/base` directory and use the Makefile included:

    cd ckan-2.9/base
    make build (can then use locally)
    make push (if you have enough credentials)

For CKAN 2.9.10 dev images, go to the `ckan-2.9/dev` directory and use the Makefile included:

    cd ckan-2.9/dev
    make build (can then use locally)
    make push (if you have enough credentials)

Same with the CKAN 2.10.3 base and dev images 

    cd ckan-2.10/base
    make build
    make push

    cd ckan-2.10/dev
    make build
    make push

### Scanning the images for vulnerabilites

<to do - provide details on the process of how we scan images - probably Docker Scout>
