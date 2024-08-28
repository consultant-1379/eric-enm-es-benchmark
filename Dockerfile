ARG OS_BASE_IMAGE_NAME=sles
ARG OS_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release
ARG OS_BASE_IMAGE_TAG=6.16.0-13

FROM $OS_BASE_IMAGE_REPO/$OS_BASE_IMAGE_NAME:$OS_BASE_IMAGE_TAG

ARG OS_BASE_IMAGE_TAG
ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified
ARG CNIV_PYPI_HOST=arm.seli.gic.ericsson.se
ARG CNIV_PYPI_REPO=$CNIV_PYPI_HOST/artifactory/proj-eric-enm-document-database-benchmark-pypi-local/

COPY image_content/requirements.txt /tmp/

RUN zypper ar -C -G -f https://arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/$OS_BASE_IMAGE_TAG?ssl_verify=no LDC-SLES15 && \
    zypper --non-interactive ref -f -r LDC-SLES15 && \
    zypper --non-interactive in curl && \
    zypper --non-interactive in python311 python311-pip && \
    pip install -I --no-cache-dir --trusted-host $CNIV_PYPI_HOST \
        --index-url https://${CNIV_PYPI_REPO} \
        -r /tmp/requirements.txt && \
    zypper clean -a

COPY image_content/*.py image_content/*.sh image_content/lib/es.sh /opt/ericsson/elasticsearch/

ENTRYPOINT ["rsyslogd", "-n"]