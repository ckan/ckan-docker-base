FROM ckan/ckan-base:master

# Tag passed through via the Makefile
ARG CKAN_TAG=${CKAN_TAG}

ENV APP_DIR=/srv/app
ENV SRC_EXTENSIONS_DIR=${APP_DIR}/src_extensions

# Install CKAN dev requirements
#RUN . ${APP_DIR}/bin/activate && \
RUN cd ${SRC_DIR}/ckan && \ 
pip3 install -r https://raw.githubusercontent.com/ckan/ckan/${CKAN_TAG}/dev-requirements.txt

# Create folder for local extensions sources
RUN mkdir -p ${SRC_EXTENSIONS_DIR}

# These are used to run https on development mode
COPY setup/unsafe.cert setup/unsafe.key ${APP_DIR}

COPY setup/start_ckan_development.sh ${APP_DIR}

CMD ["/srv/app/start_ckan_development.sh"]
