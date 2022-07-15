# Pre-configured CKAN Docker images

This is the Git repo of the official Docker images for [CKAN](https://github.com/ckan/ckan/).

The images will usually be used as a Docker Compose install in conjunction with other Docker images that make up the CKAN platform. 

The official CKAN Docker install is located here: [ckan-docker](https://github.com/ckan/ckan-docker)

The following CKAN versions are available in base or dev forms. They are distinguished from one another using different Docker image tags:

| CKAN Version | Type | Docker tag | Notes |
| --- | --- | --- | --- |
| 2.9.5 | base image | `ckan/ckan-base:2.9.5` |  |
| 2.9.5 | dev image | `ckan/ckan-base:2.9.5-dev` |  |
| 2.10.0 | base image | `ckan/ckan-base:2.10.0` | ***not implemented yet*** |
| 2.10.0 | dev image | `ckan/ckan-base:2.10.0-dev` | ***not implemented yet***|


### Building and Pushing the images

The images can be built locally and tagged appropriately so they can then be pushed into the CKAN DockerHub repo
assuming you have the correct permission to do so

For CKAN 2.9.5 base images, go to the `ckan-2.9/base` directory and use the Makefile included:

    cd ckan-2.9/base
    make build
    make push

For CKAN 2.9.5 dev images, go to the `ckan-2.9/dev` directory and use the Makefile included:

    cd ckan-2.9/dev
    make build
    make push

The CKAN 2.10 base and dev images will be available in the near future

### Scanning the images for vulnerabilites

<to do - provide details on the process of how we scan images - probably using [Synk Advisor](https://docs.docker.com/develop/scan-images/)>