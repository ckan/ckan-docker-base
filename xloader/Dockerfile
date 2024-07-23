# use the official Python 3.10 (bookworm slim) image as the base image
FROM python:3.10-slim-bookworm

# Tag passed through via the Makefile
ARG CKAN_TAG=${CKAN_TAG}
ARG XLOADER_VERSION=${XLOADER_VERSION}

ENV TZ=UTC
ENV APP_DIR=/srv/app
ENV SRC_DIR=${APP_DIR}/src
ENV CKAN_INI=${APP_DIR}/ckan.ini
ENV PIP_SRC=${SRC_DIR}
ENV CKAN_STORAGE_PATH=/var/lib/ckan
ENV GIT_URL=https://github.com/ckan/ckan.git

# Set the CKAN database connection string as an environment variable, plus set the process string for the HEALTHCHECK
ENV ckanext.xloader.jobs_db.uri="postgresql://ckandbuser:ckandbpassword@db/ckandb"
ENV WORKER_PROCESS="ckan -c /srv/app/ckan.ini jobs worker"

# Customize these in the environment (.env) file if needed
ENV CKAN_SITE_URL=http://ckan-dev:5000
ENV CKAN_CONTAINER_URL=http://ckan-dev:5000
ENV CKAN__PLUGINS image_view text_view recline_view datastore xloader envvars

# Set the working directory
WORKDIR ${APP_DIR}

# Set up timezone
RUN echo ${TZ} > /etc/timezone

# Set LC_ALL=en_US.UTF-8 will ensure that all locale-dependent operations in the current environment 
# will use English language and United States cultural conventions with UTF-8 character encoding
ENV LC_ALL=en_US.UTF-8

# Set the locale          
RUN apt-get update
RUN apt-get install --no-install-recommends -y locales
RUN sed -i "/$LC_ALL/s/^# //g" /etc/locale.gen
RUN dpkg-reconfigure --frontend=noninteractive locales 
RUN update-locale LANG=${LC_ALL}

# Install system libraries
RUN apt-get install --no-install-recommends -y \
        apt-utils \
        git \
        libpq-dev \
        g++ \
        linux-headers-generic \
        libtool \
        wget \
        procps

# Create the src directory
RUN mkdir -p ${SRC_DIR}

# Copy setup file(s) to the image
COPY setup/start_background_worker.sh ${APP_DIR}

# Install  the CKAN application, the dependency packages for CKAN plus some confiquration
RUN cd ${SRC_DIR} && \
    pip3 install -e git+${GIT_URL}@${CKAN_TAG}#egg=ckan && \
    cd ckan && \
    cp who.ini ${APP_DIR} && \
    pip3 install --no-binary markdown -r requirements.txt && \
    # Install CKAN envvars to support loading config from environment variables
    pip3 install -e git+https://github.com/okfn/ckanext-envvars.git#egg=ckanext-envvars && \
    # Create and update CKAN config
    ckan generate config ${CKAN_INI} && \
    ckan config-tool ${CKAN_INI} "beaker.session.secret = " && \
    ckan config-tool ${CKAN_INI} "ckan.plugins = ${CKAN__PLUGINS}"

# Install the XLoader extension
RUN cd ${SRC_DIR} && \
    pip3 install -e 'git+https://github.com/ckan/ckanext-xloader.git@master#egg=ckanext-xloader' && \
    pip3 install -r ckanext-xloader/requirements.txt && \
    pip3 install -U requests[security]

# Create a local user and group plus set up the storage path
RUN groupadd -g 92 ckan && \
    useradd -rm -d /srv/app -s /bin/bash -g ckan -u 92 ckan && \
    mkdir -p ${CKAN_STORAGE_PATH} && \
    chown -R ckan:ckan ${CKAN_STORAGE_PATH}

# Create entrypoint directory for children image scripts
ONBUILD RUN mkdir /docker-entrypoint.d

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s  --retries=3 \ 
  CMD pgrep ${WORKER_PROCESS} > /dev/null || exit 1

#CMD ["/bin/bash"]
CMD ["/srv/app/start_background_worker.sh"]