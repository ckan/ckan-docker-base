FROM ckan/ckan-base:2.11.0

# Tag passed through via the Makefile
ARG CKAN_VERSION=${CKAN_VERSION}

ENV APP_DIR=/srv/app
ENV SRC_EXTENSIONS_DIR=${APP_DIR}/src_extensions

# Install CKAN dev requirements
#RUN . ${APP_DIR}/bin/activate && \
RUN cd ${SRC_DIR}/ckan && \ 
pip3 install -r https://raw.githubusercontent.com/ckan/ckan/${CKAN_VERSION}/dev-requirements.txt

# Create folder for local extensions sources
RUN mkdir -p ${SRC_EXTENSIONS_DIR}

# These are used to run https on development mode
COPY setup/unsafe.cert setup/unsafe.key ${APP_DIR}

COPY setup/start_ckan_development.sh ${APP_DIR}

CMD ["/srv/app/start_ckan_development.sh"]
