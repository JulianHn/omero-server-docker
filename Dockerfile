FROM centos:centos7.9.2009@sha256:c73f515d06b0fa07bb18d8202035e739a494ce760aa73129f60f4bf2bd22b407
LABEL maintainer="ome-devel@lists.openmicroscopy.org.uk"

ENV LANG en_US.utf-8

RUN mkdir /opt/setup
WORKDIR /opt/setup
ADD playbook.yml requirements.yml /opt/setup/

RUN yum -y install epel-release \
    && yum -y install ansible sudo ca-certificates \
    && ansible-galaxy install -p /opt/setup/roles -r requirements.yml \
    && yum -y clean all \
    && rm -fr /var/cache

ARG OMERO_VERSION=5.6.7
ARG OMEGO_ADDITIONAL_ARGS=
ENV OMERODIR=/opt/omero/server/OMERO.server/
RUN ansible-playbook playbook.yml \
    -e omero_server_release=$OMERO_VERSION \
    -e omero_server_omego_additional_args="$OMEGO_ADDITIONAL_ARGS" \
    && yum -y clean all \
    && rm -fr /var/cache

RUN curl -L -o /usr/local/bin/dumb-init \
    https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 && \
    chmod +x /usr/local/bin/dumb-init
ADD entrypoint.sh /usr/local/bin/
ADD 50-config.py 60-database.sh 99-run.sh /startup/

USER omero-server
EXPOSE 4063 4064
VOLUME ["/OMERO", "/opt/omero/server/OMERO.server/var"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
