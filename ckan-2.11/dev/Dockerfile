FROM ckan/ckan-base:2.11.0

# Tag passed through via the Makefile
ARG CKAN_VERSION=${CKAN_VERSION}

ENV APP_DIR=/srv/app
ENV SRC_EXTENSIONS_DIR=${APP_DIR}/src_extensions

USER root

# Install CKAN dev requirements
RUN cd ${SRC_DIR}/ckan && \ 
pip3 install -r https://raw.githubusercontent.com/ckan/ckan/${CKAN_VERSION}/dev-requirements.txt

COPY --chown=ckan-sys:ckan-sys setup/unsafe.cert setup/unsafe.key setup/start_ckan_development.sh ${APP_DIR}

# Update local directories
RUN mkdir -p ${SRC_EXTENSIONS_DIR} /var/lib/ckan && \
    chown -R ckan:ckan-sys ${SRC_EXTENSIONS_DIR} ${APP_DIR}/ckan.ini /var/lib/ckan/

USER ckan

CMD ["/srv/app/start_ckan_development.sh"]
