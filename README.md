Pre-configured CKAN Docker images

The following CKAN versions are available as different image tags:

| CKAN Version | type | Docker tag | Notes |
| --- | --- | --- | --- | --- |
| 2.9.5 | base image | `ckan/ckan-base:2.9.5` |  |
| 2.9.5 | dev image | `ckan/ckan-base:2.9.5-dev` |  |
| 2.10.0 | base image | `ckan/ckan-base:2.10.0` | not implemented yet |
| 2.10.0 | dev image | `ckan/ckan-base:2.10.0-dev` | not implemented yet|


### Building and Pushing the images

For CKAN 2.9.5 base images, go to the `ckan-2.9/base` directory and use the Makefile included:

    make build
    make push

For CKAN 2.9.5 dev images, go to the `ckan-2.9/dev` directory and use the Makefile included:

    make build
    make push

