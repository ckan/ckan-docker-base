ARG ENV=base
ARG PYTHON_VERSION=3.14


# ┌─────────────────────────────────────────────────────────────┐
# │                                                             │
# │ Builder stage                                               │
# │ -------------                                               │
# │                                                             │
# │ Compiles Python deps, later used by the next buid via       │
# │ multi-stage copy.                                           │
# │                                                             │
# └─────────────────────────────────────────────────────────────┘


FROM python:${PYTHON_VERSION}-slim-bookworm AS builder

ARG CKAN_REF

ENV APP_DIR=/srv/app
ENV SRC_DIR=${APP_DIR}/src
ENV CKAN_INI=${APP_DIR}/ckan.ini
ENV PIP_SRC=${SRC_DIR}
ENV GIT_URL=https://github.com/ckan/ckan.git
ENV CKAN__PLUGINS="image_view text_view datatables_view datastore envvars"

WORKDIR ${APP_DIR}

# Build dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        g++ \
        git \
        libpq-dev \
        libtool \
        patch \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${SRC_DIR}

# Install uwsgi, CKAN, the CKAN requirements and ckanext-envvars,
# and create the default ckan.ini file
RUN pip3 install -U pip && \
    pip3 install -U "setuptools==81" && \
    pip3 install uwsgi && \
    cd ${SRC_DIR} && \
    pip3 install -e git+${GIT_URL}@${CKAN_REF}#egg=ckan && \
    cd ckan && \
    pip3 install --no-binary markdown -r requirements.txt && \
    pip3 install -e git+https://github.com/okfn/ckanext-envvars.git@v0.0.6#egg=ckanext-envvars && \
    ckan generate config ${CKAN_INI} && \
    ckan config-tool ${CKAN_INI} "SECRET_KEY = " && \
    ckan config-tool ${CKAN_INI} "ckan.plugins = ${CKAN__PLUGINS}"


# ┌─────────────────────────────────────────────────────────────┐
# │                                                             │
# │ Base image (Production env)                                 │
# │ ---------------------------                                 │
# │ This is always built                                        │
# │                                                             │
# └─────────────────────────────────────────────────────────────┘


FROM python:${PYTHON_VERSION}-slim-bookworm AS base

# Tag passed through via the Makefile
ARG CKAN_REF
# Make it available to child images
ENV CKAN_REF=${CKAN_REF}

# Internals, you probably don't need to change these
ENV TZ=UTC
ENV APP_DIR=/srv/app
ENV SRC_DIR=${APP_DIR}/src
ENV CKAN_INI=${APP_DIR}/ckan.ini
ENV PIP_SRC=${SRC_DIR}
ENV CKAN_STORAGE_PATH=/var/lib/ckan
ENV GIT_URL=https://github.com/ckan/ckan.git

# Customize these in the environment (.env) file if needed
ENV CKAN_SITE_URL=http://localhost:5000
ENV CKAN__PLUGINS="image_view text_view datatables_view datastore envvars"

# UWSGI options
ENV UWSGI_HARAKIRI=50

# Set LC_ALL=en_US.UTF-8 will ensure that all locale-dependent operations in the current environment
# will use English language and United States cultural conventions with UTF-8 character encoding
ENV LC_ALL=en_US.UTF-8

WORKDIR ${APP_DIR}

# Runtime system dependencies and locales setup
RUN echo ${TZ} > /etc/timezone && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        curl \
        libmagic1 \
        libpq5 \
        locales && \
    sed -i "/$LC_ALL/s/^# //g" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=${LC_ALL} && \
    rm -rf /var/lib/apt/lists/*

# Copy built Python environment, src dir and ini file
COPY --from=builder /usr/local /usr/local
COPY --from=builder ${SRC_DIR} ${SRC_DIR}
COPY --from=builder ${CKAN_INI} ${CKAN_INI}

# Create ckan and ckan-sys users and the ckan-sys group plus set up the storage path
RUN groupadd -g 502 ckan-sys && \
    useradd -rm -d /srv/app -s /bin/bash -g ckan-sys -u 502 ckan-sys && \
    useradd -rm -d /srv/app -s /bin/bash -g ckan-sys -u 503 ckan

COPY setup/prerun.py ${APP_DIR}
COPY setup/start_ckan.sh ${APP_DIR}
ADD https://raw.githubusercontent.com/ckan/ckan/${CKAN_REF}/wsgi.py ${APP_DIR}
RUN chmod 644 ${APP_DIR}/wsgi.py

# Set up paths and permissions
# 1. Docker entrypoint for init scripts
# 2. Ini file
# 3. Src dir
# 4. Storage dir
RUN mkdir -p /docker-entrypoint.d && \
    chmod 755 /docker-entrypoint.d && \
    chown ckan-sys:ckan-sys /docker-entrypoint.d && \
    chown -R ckan-sys:ckan-sys ${APP_DIR} && \
    chown ckan:ckan-sys ${APP_DIR}/ckan.ini && \
    mkdir -p ${CKAN_STORAGE_PATH} && \
    chown -R ckan:ckan-sys ${CKAN_STORAGE_PATH}

USER ckan

EXPOSE 5000

CMD ["/srv/app/start_ckan.sh"]


# ┌─────────────────────────────────────────────────────────────┐
# │                                                             │
# │ Dev image (Development env)                                 │
# │ ---------------------------                                 │
# │ This is only built when ENV=dev                             │
# │                                                             │
# └─────────────────────────────────────────────────────────────┘


FROM base AS dev

ENV SRC_EXTENSIONS_DIR=${APP_DIR}/src_extensions

USER root

# Reinstall build tools to install extensions and their requirements
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        g++ \
        git \
        libpq-dev \
        patch && \
    cd ${SRC_DIR}/ckan && \
    pip3 install -r https://raw.githubusercontent.com/ckan/ckan/${CKAN_REF}/dev-requirements.txt && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=ckan-sys:ckan-sys setup/unsafe.cert setup/unsafe.key setup/start_ckan_development.sh setup/install_src.sh ${APP_DIR}

# Set directories and permissions
RUN mkdir -p ${SRC_EXTENSIONS_DIR} && \
    chown -R ckan-sys:ckan-sys ${SRC_EXTENSIONS_DIR} && \
    chmod 775 ${SRC_EXTENSIONS_DIR}

USER ckan

CMD ["/srv/app/start_ckan_development.sh"]


# ──────────────────────────────────────────────────────────────


FROM ${ENV} AS final
