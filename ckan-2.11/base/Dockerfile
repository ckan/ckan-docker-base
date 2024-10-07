FROM python:3.10-slim-bookworm

# Tag passed through via the Makefile
ARG CKAN_VERSION=${CKAN_VERSION}

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
        wget

# Create the src directory
RUN mkdir -p ${SRC_DIR}

# Install uwsgi, the CKAN application, the dependency packages for CKAN plus some confiquration
RUN pip3 install -U pip && \
    pip3 install uwsgi && \
    cd ${SRC_DIR} && \
    pip3 install -e git+${GIT_URL}@${CKAN_VERSION}#egg=ckan && \
    cd ckan && \
    pip3 install --no-binary markdown -r requirements.txt && \
    # Install CKAN envvars to support loading config from environment variables
    pip3 install -e git+https://github.com/okfn/ckanext-envvars.git@v0.0.6#egg=ckanext-envvars && \
    # Create and update CKAN config
    ckan generate config ${CKAN_INI} && \
    ckan config-tool ${CKAN_INI} "SECRET_KEY = " && \
    ckan config-tool ${CKAN_INI} "ckan.plugins = ${CKAN__PLUGINS}"

# Create a local user and group plus set up the storage path
RUN groupadd -g 92 ckan && \
    useradd -rm -d /srv/app -s /bin/bash -g ckan -u 92 ckan && \
    mkdir -p ${CKAN_STORAGE_PATH} && \
    chown -R ckan:ckan ${CKAN_STORAGE_PATH}

COPY setup/prerun.py ${APP_DIR}
COPY setup/start_ckan.sh ${APP_DIR}
ADD https://raw.githubusercontent.com/ckan/ckan/${CKAN_VERSION}/wsgi.py ${APP_DIR}
RUN chmod 644 ${APP_DIR}/wsgi.py

# Create entrypoint directory for children image scripts
ONBUILD RUN mkdir /docker-entrypoint.d

EXPOSE 5000

CMD ["/srv/app/start_ckan.sh"]
